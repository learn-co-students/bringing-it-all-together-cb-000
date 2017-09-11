class Dog

  attr_accessor :name, :breed, :id

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name],breed: hash[:breed])
    dog.save
  end

  def self.find_or_create_by(arg)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    blah = DB[:conn].execute(sql,arg[:name],arg[:breed]).flatten
    if blah[0] == nil
      create(name: blah[1],breed: blah[2])
    else
      dog = Dog.new(name: blah[1], breed: blah[2], id: blah[0])
    end
  end

  def self.new_from_db(arg)
    dog = Dog.new(id:arg[0],name:arg[1],breed:arg[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    blah = DB[:conn].execute(sql,name).flatten
    new_from_db(blah)

  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    blah = DB[:conn].execute(sql,id).flatten
    dog = Dog.new(name: blah[1], breed:blah[2], id:blah[0])
  end

  def initialize(name:, breed:, id: nil)
    self.name, self.breed, self.id = name, breed, id
  end

  def save
    if id
      update
    else
      sql= <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql,self.name,self.breed)
      self.id = DB[:conn].execute('SELECT last_insert_rowid() from dogs')[0][0]
    end
    return self
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end


end
