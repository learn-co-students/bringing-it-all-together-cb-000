class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
  end

  def self.create(name:, breed:)
    new = Dog.new(name, breed)
    song.save
    song
  end

  def self.create_table
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save

    sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      result = DB[:conn].execute(sql, self.name, self.breed)
      new_from_db(result)
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(name)

    sql = "SELECT * FROM dogs WHERE name = ?"

    DB[:conn].execute(sql, name)
    # for whatever reason, return is blank - not finding "Teddy"
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM songs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(result[0], result[1], result[2])
  end

end
