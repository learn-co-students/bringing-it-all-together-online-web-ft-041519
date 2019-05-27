class Dog
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed: )
    @id = id 
    @name = name 
    @breed = breed 
  end
  
  def self.create_table 
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql =  <<-SQL
      DROP TABLE IF EXISTS dogs
        SQL
    DB[:conn].execute(sql)
  end 
  
  def save
    if !@id 
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      dog = DB[:conn].execute(sql, self.name, self.breed) 
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else 
      sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ? 
      SQL
      dog = DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 
    self 
  end 
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end 
  
  def self.find_by_id(id) 
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end 
  
  def self.find_or_create_by(name:, breed:)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      
      if !DB[:conn].execute(sql, name, breed)[0] 
        self.create(name: name, breed: breed)
      else
        result = DB[:conn].execute(sql, name, breed)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
      end 
  end 
  
  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id: result[0], name: result[1], breed: result[2])
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?"
    DB[:conn].execute(sql, self.name)
  end 
  
end 