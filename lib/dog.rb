class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGERY PRIMARY KEY,
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
    if !self.id
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    newDog = Dog.new(name:name, breed:breed)
    newDog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    newDog = DB[:conn].execute(sql,id)[0]
    fido = Dog.new(id:newDog[0],name:newDog[1],breed:newDog[2])
    fido
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT id
    FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL
    found = DB[:conn].execute(sql,name, breed)[0]
    if found != nil
      Dog.find_by_id(found[0])
    else
      newPup = Dog.create(name:name, breed:breed)
    end
  end

  def self.new_from_db(arr)
    Dog.new(id:arr[0], name:arr[1], breed:arr[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT id
    FROM dogs
    WHERE name = ?
    SQL
    found = DB[:conn].execute(sql,name)[0]
    if found != nil
      Dog.find_by_id(found[0])
    else
      newPup = Dog.create(name:name, breed:breed)
    end
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
