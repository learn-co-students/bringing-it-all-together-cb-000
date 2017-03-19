class Dog

	attr_accessor :name, :breed
	attr_reader :id

	def self.create_table()
		DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
	end

	def self.drop_table()
		DB[:conn].execute("DROP TABLE dogs")
	end

	def self.create(hash)
		Dog.new(hash).save #Returns new instance
	end

	def self.find_by_id(id)
		new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id=?", id)[0])
	end

	def self.find_or_create_by(hash)
		res = new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", hash[:name], hash[:breed])[0])
		res = create(hash) unless res
		res
	end

	def self.find_by_name(name)
		new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name=?", name)[0])
	end

	def self.new_from_db(row)
		return nil if row==nil
		self.new(id: row[0], name: row[1], breed: row[2])
	end

	def initialize(id: nil, name: nil, breed: nil)
		@id = id
		@name = name
		@breed = breed
	end

	def save()
		if id
			update
		else
			DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES (?,?)", name, breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
		end
		self
	end

	def update()
		DB[:conn].execute("UPDATE dogs SET name=?, breed=? WHERE id=?", name, breed, id)
	end

end