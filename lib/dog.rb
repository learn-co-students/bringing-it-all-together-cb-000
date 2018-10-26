class Dog 
  attr_accessor :name, :breed 
  
  attr_reader :id 
  
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def self.create(dog_data)
    dog = new(dog_data)
    dog.save
    dog 
  end 
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs 
      WHERE id = ?
      LIMIT 1 
      SQL
    DB[:conn].execute(sql, id).map do |row|
      new_from_db(row)
    end.first 
  end 
  
  def self.new_from_db(row)
    id, name, breed = row # [number, string, string]
    new(id: id, name: name, breed: breed)
  end 
  
    
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT *
      FROM dogs 
      WHERE name = ?
      LIMIT 1 
      SQL
    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(data)
    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE name = ? AND breed = ?
      SQL
      
    dog = DB[:conn].execute(sql, data[:name], data[:breed]).first
    
    if !dog
      create(data)
    else 
      new_from_db(dog)
    end 
  end 
  
  def initialize(id: nil, name: '', breed: '')
    @id = id
    @name = name
    @breed = breed
  end 

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
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
      @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    end 
    self
  end 
  
  private
  def defaults
    {id: nil}
  end
end 










