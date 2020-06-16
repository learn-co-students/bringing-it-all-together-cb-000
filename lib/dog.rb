class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash=nil)
    hash.each do |key, value|
      instance_variable_set("@#{key}", value) unless value.nil?
    end
    @id ||= nil
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
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    i = self.new(hash)
    i.save
    i
  end

  def self.new_from_db(row_array)
    hash = Hash.new
    hash[:id] = row_array[0]
    hash[:name] = row_array[1]
    hash[:breed] = row_array[2]
    self.new(hash)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    a = DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
    end.first
    a.id = id
    a
  end

  def self.find_or_create_by(hash)
    name = hash[:name]
    breed = hash[:breed]
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    result = DB[:conn].execute(sql, name, breed).flatten

    if !result.empty?
      dog = self.new_from_db(result)
    else
      dog = self.create(hash)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name).flatten
    self.new_from_db(result)
  end

end
