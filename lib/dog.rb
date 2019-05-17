class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if !self.id
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    else
      sql = <<-SQL
      UPDATE dogs
      SET dogs.name = ?, dogs.breed = ?
      WHERE dogs.id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new(name: row[1], breed: row[2], id: row[0])
    end[0]
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.name = ? AND dogs.breed = ?
    SQL

    search = DB[:conn].execute(sql, name, breed)
    if search.empty?
      self.create(name: name, breed: breed)
    else
      search.map do |row|
        self.new(name: row[1], breed: row[2], id: row[0])
      end[0]
    end
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end[0]
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
