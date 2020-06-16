require 'pry'

class Dog 
  
  # has a name and a breed
  attr_accessor :name, :breed 
  attr_reader :id
  
  # has an id that defaults to `nil` on initialization
  # accepts key value pairs as arguments to initialize
  def initialize(id:nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed
  end
  
  # creates the dogs table in the database 
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

  # drops the dogs table from the database
  def self.drop_table
    sql = <<-SQL
            DROP TABLE dogs
          SQL
    DB[:conn].execute(sql)  
  end
  
  # returns an instance of the dog class
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end 
  end

  def update 
  end
  
  # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save 
    dog
  end 
  
  # returns a new dog object by id
  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ? LIMIT 1
      SQL
    result = DB[:conn].execute(sql,id).flatten
    self.new_from_db(result)
  end 
  
  def self.new_from_db(row)
    params = {id: row[0], name: row[1],breed: row[2]}
    new_dog = self.new(params)  
    new_dog  
  end
  
  #  creates an instance of a dog if it does not already exist
  # when two dogs have the same name and different breed, it returns the correct dog
  # when creating a new dog with the same name as persisted dogs, it returns the correct dog 
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT * FROM dogs WHERE name = ? and breed = ?
        SQL
    results = DB[:conn].execute(sql,name,breed).flatten
    if !results[0].nil?
      self.new_from_db(results)
    else 
      self.create(name:name, breed:breed)
    end

  end
  
  # returns an instance of dog that matches the name from the DB
  def self.find_by_name(name) 
    sql = <<-SQL
          SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
    results = DB[:conn].execute(sql,name).flatten
    self.new_from_db(results)
  end
  
  # updates the record associated with a given instance
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
end