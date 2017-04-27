class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil,name:, breed:)
    @id = id
    @name = name
    @breed = breed

  end


  def self.create_table #module
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table  #module
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
=begin  sql = "SELECT * FROM dogs WHERE id = ?"
      DB[:conn].execute(sql, id).collect do |row|
        hash = {:id => row[0], :name => row[1], :breed => row[2]}
        self.new(hash)
      end.first
=end
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
      end
      self
  end



 def self.create(hash)
   dog = Dog.new(hash)
   dog.save
   end

 def self.find_by_id(id)
     sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        LIMIT 1
     SQL

     DB[:conn].execute(sql, id).collect do |row|
       hash = {:id => row[0], :name => row[1], :breed => row[2]}
       self.new(hash)
     end.first

 end

 def self.find_or_create_by(hash)
   sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
   row = DB[:conn].execute(sql,hash[:name],hash[:breed])

   if !row.empty?
     row = row[0]
    dog = self.new_from_db(row)
  else
     dog = self.create(hash)
   end
   dog
end


def self.new_from_db(row)
   # create a new Student object given a row from the database
      hash = {:id => row[0], :name => row[1], :breed => row[2]}
   dog = Dog.new(hash)

   dog
 end

 def self.find_by_name(name)
   sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
      DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
      end.first
end


 def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed,self.id)
end

end
