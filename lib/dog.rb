class Dog
  attr_accessor :id, :name, :breed
  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    if hash[:id] != nil
      @id = hash[:id]
    else
      @id = nil
    end
  end
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end
  def save
  if @id == nil
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    else
      self.update
      self
    end
  end
  def self.create(hash)
    stud = self.new(hash)
    stud.save
    stud
  end
  def self.find_by_name(name)
    sql = <<-SQL
     SELECT * FROM dogs
     WHERE name = ? ;
    SQL
   row = DB[:conn].execute(sql, name)
   self.new_from_db(row[0])
  end
  def self.new_from_db(row)
    hash = {id: row[0], name: row[1], breed: row[2]}
    stud = self.new(hash)
    stud.save
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  def self.find_by_id(id)
    sql = <<-SQL
     SELECT * FROM dogs
     WHERE id = ? ;
    SQL
   row = DB[:conn].execute(sql, id)[0]
   doggo = self.new_from_db(row)
   doggo
  end
  def self.find_or_create_by(hash)
    name = hash[:name]
    breed = hash[:breed]
    sql =  "SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?;"

    row = DB[:conn].execute(sql, name, breed)
    if row[0]
      self.find_by_id(row[0][0])
    else
      self.create(hash)
    end
  end
end
