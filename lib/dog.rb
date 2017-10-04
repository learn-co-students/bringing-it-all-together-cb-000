class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES
      (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    self.id = DB[:conn].last_insert_row_id()

    self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, id).flatten

    self.new(id: dog_array[0], name: dog_array[1], breed: dog_array[2])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog_array = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten

    if dog_array.empty?
      self.create(hash)
    else
      self.find_by_id(dog_array[0])
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    dog_array = DB[:conn].execute(sql, name).flatten

    self.find_by_id(dog_array[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
