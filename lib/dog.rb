# Dog ORM
class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
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
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(dog_id)
    row = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', dog_id)
    dog = new_from_db(row)
    dog
  end

  def self.new_from_db(row)
    row.flatten!
    id, name, breed = row[0], row[1], row[2]
    dog = self.new(name: name, breed: breed)
    dog.id = id
    dog
  end
end
