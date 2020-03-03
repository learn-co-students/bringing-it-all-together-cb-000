class Dog
    attr_accessor :name, :breed, :id

    def initialize (id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            album TEXT
            )
            SQL
        DB[:conn].execute(sql)
      end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        return self
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]

        self.new(id: id, name: name, breed: breed)
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first 
    end 

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL
      
        dog = DB[:conn].execute(sql,name,breed)
            
            if !dog.empty?
            dd = dog[0]
            dog = Dog.new(id: dd[0], name: dd[1], breed: dd[2])
            else
            dog = self.create(name: name, breed: breed)
            end
        dog 
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog = DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end