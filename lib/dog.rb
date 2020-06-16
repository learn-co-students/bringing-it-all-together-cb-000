class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash)
    hash.each {|k,v| self.send("#{k}=", v)}
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

  def self.new_from_db(arr)
    hash = {
      :id => arr[0],
      :name => arr[1],
      :breed => arr[2]
    }
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
              SQL
      DB[:conn].execute(sql,name).map {|row| Dog.new_from_db(row)}[0]
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if @id == nil
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?,?)
          SQL
          DB[:conn].execute(sql,@name,@breed)

          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      self.update
    end
    self
  end

  def self.create(hash)
    Dog.new(hash).tap { |dog|
      dog.save
    }
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
              SQL
      DB[:conn].execute(sql,id).map {|row| Dog.new_from_db(row)}[0]
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !row.empty?
        dog = Dog.new_from_db(row[0])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end
end
