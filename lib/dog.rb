require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
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

  def update
    sql = <<-SQL
      UPDATE dogs(name,breed)
      VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save
    if self.id
      self.update
    else
      # Not persisted into the db (use INSERT)
      sql = <<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    doggo = Dog.new(id: self.id, name: self.name, breed: self.breed)
  end

  def self.create(*args)
    doggo = Dog.new(*args)
    doggo.save
  end

  def self.find_by_id(given_id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql,given_id)
    doggo = Dog.new(id: given_id, name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name: , breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND
      WHERE breed = ?
    SQL
    doggo = DB[:conn].execute(sql,name,breed)

    if !doggo.empty?
      doggo_attr = doggo[0]
      doggo = Dog.new(doggo_attr[0], name: doggo_attr[1], breed: doggo_attr[2])
    else
      doggo = Dog.create(name: name,breed: breed)
    end
    doggo
  end
end
