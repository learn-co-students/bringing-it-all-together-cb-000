
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name  TEXT, breed  TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(x)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", x).flatten
    dogs = Dog.new(id: x, name: dog[1], breed: dog[2])
    dogs
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(array)
    dog = Dog.new(id: array[0], name: array[1], breed: array[2])
    dog
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? ", name).flatten
    new_dog = Dog.new(id: dog[0], name: name, breed: dog[2])
    new_dog
  end



end
