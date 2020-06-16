class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
  end

  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    new_dog
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

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      self


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

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
      end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
      end.first
  end

  def self.find_or_create_by(name:, breed:)

    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]

    if !row.nil?
      dog = self.new_from_db(row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
    
  end

end
