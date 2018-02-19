require_relative "../config/environment.rb"

class Dog
  # has a name and a breed
  attr_accessor :name, :breed, :id

  # has an id that defaults to `nil` on initialization
  # accepts key value pairs as arguments to initialize
  def initialize(id: nil, name:, breed:)
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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  # returns an instance of the dog class
  # saves an instance of the dog class to the database and then sets the given dog's `id` attribute
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

end
