class Dog
attr_accessor :name, :breed
attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY key,
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
        INSERT INTO dogs (name,breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.create name:, breed:
    dog = self.new name: name, breed: breed
    dog.save
  end

  def self.find_by_id id
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def self.new_from_db row
    self.new id: row[0], name: row[1], breed: row[2]
  end

  def self.find_or_create_by name:, breed:
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    dog_info = DB[:conn].execute(sql, name, breed).flatten
    if !dog_info.empty?
      new_from_db dog_info[0]
    else
      create(name: name, breed: breed)
    end
  end

  def self.find_by_name name
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    dog_info = DB[:conn].execute(sql, name).flatten
    new_from_db dog_info
  end

  # I'll work on this when I learn more about metaporgramming and using *args
  # def self.find_by *args
  #   args.each do |k,v|
  #
  # end
end
