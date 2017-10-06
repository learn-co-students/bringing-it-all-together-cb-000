require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(args)
    if args[:id]
      @id = args[:id]
    end
    @name = args[:name]
    @breed = args[:breed]
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    # if self.id
    #   self.update
    # else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    # end
    self
  end

  def self.create(row)
    # takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database (FAILED - 1)
    dog = Dog.new(name: row[:name], breed: row[:breed])
    dog.save
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    # binding.pry
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(row)
    dog = self.find_by(row)
    # dog = self.find_by_name(row)
    if !dog
    dog = self.create(row)
    end
    dog
  end

  def self.find_by(row)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,row[:name], row[:breed]).map do |row|
      self.new_from_db(row)
    end.first
  end



  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(arr)
    dog_id = arr[0]
    dog_breed = arr[2]
    dog_name = arr[1]
    dog = Dog.new(id:dog_id, name:dog_name, breed:dog_breed)

  end


end
