class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def Dog::create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def Dog::drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def Dog::new_from_db(row)
        row = row.flatten
        id = row[0]
        name = row[1]
        breed = row[2]

        self.new(name: name, breed: breed, id: id)
    end

    def Dog::create(hash)
        self.new(name: hash[:name], breed: hash[:breed]).save
    end

    def Dog::find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id).flatten

        self.new_from_db(row)
    end

    def Dog::find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        row = DB[:conn].execute(sql, name).flatten

        self.new_from_db(row)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, name, breed, id)
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
            self
        end
    end

    def Dog::find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        row = DB[:conn].execute(sql, name, breed).flatten

        if !row.empty?
            self.new_from_db(row)
        else
            self.create(name: name, breed: breed)
        end
    end
end