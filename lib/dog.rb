class Dog
  attr_reader :id
  attr_accessor :name, :breed
  def initialize(name: name, breed: breed, id: id)
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

  def save
    if self.id
      self.update
    else
      self.insert
    end
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  def self.create(name: name, breed: breed)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE breed = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name: name, breed: breed)
    self.find_by_name_and_breed(name: name, breed: breed) || \
    self.create(name: name, breed: breed)
  end
  def self.find_by_name_and_breed(name: name, breed: breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name, breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
  end
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
