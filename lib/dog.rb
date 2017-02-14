class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil,name:,breed:)
    @name, @breed, @id = name, breed, id
  end

  def self.create_table
    # DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs(id PRIMARY KEY, name TEXT, breed TEXT')
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def save
    sql = 'INSERT INTO dogs (name, breed) VALUES (?,?)'
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(hash)
    self.new(hash).save 
  end

  def self.new_from_db(row)
    self.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ?'
    row = DB[:conn].execute(sql,id).first
    self.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ? LIMIT 1'
    row = DB[:conn].execute(sql,name).first
    self.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1'
    row = DB[:conn].execute(sql, hash[:name], hash[:breed]).first
    row ? self.new_from_db(row) : self.create(hash)
    # dog = nil
    # if !row
    #   dog = self.create(hash)
    # else 
    #   dog = self.new_from_db(row)
    # end
    # dog
  end

  def update
    sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

end