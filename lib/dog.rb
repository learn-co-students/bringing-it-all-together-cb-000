require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize( name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end


  def save
    sql = "INSERT INTO dogs (name, breed) values (?,?)"
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self 
  end


  def update
    sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id=?",id)[0]
    Dog.new_from_db(row)
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name=?",name)[0]
    Dog.new_from_db(row)
  end


  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?",name, breed)[0]
    row ? Dog.new_from_db(row): Dog.create({name: name, breed: breed}) 
  end


  def self.new_from_db(row)
    Dog.new({name: row[1], breed: row[2] , id: row[0]})
  end


  def self.create(hash)
    Dog.new(hash).tap(&:save)
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs
      ( id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end


  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

end

