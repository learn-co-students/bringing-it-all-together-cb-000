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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.id)
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    params = { 
      id: dog_data[0], 
      name: dog_data[1], 
      breed: dog_data[2] 
    }
    dog = self.new(params)
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    data = DB[:conn].execute(sql, name, breed)[0]
    if !data.nil?
      dog = self.new(id: data[0], name: data[1], breed: data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    dog = self.new(id: data[0], name: data[1], breed: data[2])
    dog
  end
end



