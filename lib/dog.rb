class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = attributes[:id]
  end 

  def self.new_from_db(row)
    new_dog = self.new Hash.new()
    new_dog.id = row[0]
    new_dog.name =  row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.all
    # retrieve all the rows from the "Dogs" database
    DB[:conn].execute('SELECT id, name, breed FROM dogs').map do |dog_info|
      self.new_from_db(dog_info)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT id, name, breed FROM dogs WHERE name = :name LIMIT 1" 
    DB[:conn].execute(sql, name).map do |dog_info| 
      self.new_from_db(dog_info)
    end.first
  end

  def self.find_by_name_and_breed(name_and_breed)
    sql = "SELECT id, name, breed FROM dogs WHERE name = :name and breed = :breed LIMIT 1" 
    DB[:conn].execute(sql, 
                      :name => name_and_breed[:name],
                      :breed => name_and_breed[:breed]
                     ).map do |dog_info| 
      self.new_from_db(dog_info)
    end.first
  end

  def self.find_or_create_by(name_and_breed)
    self.find_by_name_and_breed(name_and_breed) || self.create(name_and_breed)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def update
     DB[:conn].execute("UPDATE dogs SET name = :name, breed = :breed WHERE id = :id", @name, @breed, @id)
  end

  def self.find_by_id(id)
    sql = "SELECT id, name, breed FROM dogs WHERE id = :name LIMIT 1" 
    DB[:conn].execute(sql, id).map do |dog_info| 
      self.new_from_db(dog_info)
    end.first
  end

  def self.create(name_and_breed)
    dog = self.new(name_and_breed)
    dog.save
    dog
  end

  def save
    if @id.nil?
     DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES(:name, :breed)", "name" => @name, "breed" => @breed)
     @id = DB[:conn].last_insert_row_id
   else
     self.update
   end
     self
  end

  def self.create_table
    # replace spaces preceeded by pipe with empty string and
    # replace carriage returns and new lines with a space
    sql = <<-END_SQL.gsub(/^\s+\|/, '').gsub("[\r\n]", ' ')
      | CREATE TABLE IF NOT EXISTS dogs (
      |   id INTEGER PRIMARY KEY,
      |   name TEXT, 
      |   breed TEXT
      | );
    END_SQL
    DB[:conn].execute sql
  end 

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute sql
  end
end
