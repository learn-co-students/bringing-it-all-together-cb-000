class Dog

  attr_accessor :name, :breed, :id

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
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
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    # binding.pry
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(name: result[1], breed: result[2])
    dog.id = id
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(name: result[1], breed: result[2])
    dog.id = result[0]
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    result = DB[:conn].execute(sql, name, breed)
    if result.empty?
      dog = create(name: name, breed: breed)
    else
      dog = Dog.new(id: result[0][0], name: result[0][1], breed: result[0][2])
    end
    dog
  end

  def self.new_from_db(args)
    id = args[0]
    name = args[1]
    breed = args[2]
    Dog.new(id: id, name: name, breed: breed)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end
end