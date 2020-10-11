require_relative "../config/environment.rb"

class Dog

attr_accessor :name, :breed,:id



def initialize(id: nil,name:,breed:)


    @name = name
    @breed = breed

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
  sql = <<-SQL
    INSERT INTO dogs(name,breed) VALUES (?,?)
  SQL
  DB[:conn].execute(sql,self.name,self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid();")[0][0]
  self

end

def self.create(attributes)
    new_dog = Dog.new(name:"",breed: "")
    attributes.each {|key, value| new_dog.send(("#{key}="), value)}
    new_dog.save
    new_dog
end

def self.new_from_db(row)
new_dog = self.new(name: "",breed: "")
new_dog.id = row[0]
new_dog.name = row[1]
new_dog.breed = row[2]
new_dog

end


def self.find_by_id(id)
  sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
  self.new_from_db(DB[:conn].execute(sql,id)[0])


end

def self.find_or_create_by(name:,breed:)
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ? AND breed = ?
  SQL
  store = (DB[:conn].execute(sql,name,breed))
  if !store.empty?
    new_dog = self.new_from_db(store[0])
  else
   new_dog=  self.new_from_db(store)
   new_dog.save

  end
  new_dog


end


def self.find_by_name(name)
  sql = <<-SQL
  SELECT * FROM dogs WHERE name = ?
  SQL
  store = (DB[:conn].execute(sql,name)[0])
   self.new_from_db(store)
end


def update
  sql  = <<-SQL
  UPDATE dogs SET name = ? , breed = ? WHERE id = ?
  SQL
  DB[:conn].execute(sql,self.name,self.breed,self.id)


end


end
