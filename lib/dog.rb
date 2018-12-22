class Dog
  attr_accessor :name, :breed, :id
  #attr_reader :id
  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("""
    create table if not exists dogs(id integer primary key,
                                    name text,
                                    breed, text);
    """)
  end

  def self.drop_table
    DB[:conn].execute("drop table dogs;")
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("select * from dogs where id = ?;", id)[0]
    dog = self.new_from_db(row)
  end
  def save
    if @id
      update
    else
      DB[:conn].execute("""
        insert into dogs (name, breed) values (?, ?)
      """, @name, @breed)
      @id = DB[:conn].execute("select last_insert_rowid() from dogs;")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new
    dog.name = name
    dog.breed = breed
    dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("select * from dogs where name = ? and breed = ?;", name, breed)
    if !row.empty?
      data = row[0]
      dog = self.new_from_db(data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog = self.new
    dog.name = row[1]
    dog.breed = row[2]
    dog.id = row[0]
    dog
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("select * from dogs where name = ?;", name)[0]
    dog = self.new_from_db(row)
  end

  def update
    DB[:conn].execute("update dogs set name = ?, breed = ?;", @name, @breed)
  end
end
