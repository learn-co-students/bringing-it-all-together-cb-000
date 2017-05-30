class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(name:,breed:,id:nil)
    @name=name
    @breed=breed
    @id=id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES (?,?)",@name,@breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(dog)
    d = self.new(dog)
    d.save
  end

  def self.find_by_id(id)
    d = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",id)[0]
    self.new_from_db(d)
  end

  def self.find_or_create_by(name:,breed:)
    d = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?",name,breed)

    if d.empty?
      hash_dog = {name:name,breed:breed,id:nil}
      dog = self.create(hash_dog)
    else

      dog = self.new_from_db(d[0])
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(name:row[1],breed:row[2],id:row[0])
  end


  def self.find_by_name(name)
    self.new_from_db( DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name)[0] )
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name=?,breed=? WHERE id = ?",@name,@breed,@id)
  end














end
