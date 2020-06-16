class Dog
  TABLE_NAME = "dogs"

  class << self
    def create_table()
      DB[:conn].execute("CREATE TABLE IF NOT EXISTS #{TABLE_NAME} " +
                            "(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def drop_table()
      DB[:conn].execute("DROP TABLE IF EXISTS #{TABLE_NAME};")
    end

    def create(attributes)
      return Dog.new(attributes).save
    end

    def new_from_db(row)
      return self.new({id: row[0], name: row[1], breed: row[2]})
    end

    def find_by_id(id)
      sql = "SELECT id, name, breed FROM #{TABLE_NAME} WHERE id = ?"
      return DB[:conn].execute(sql,id).collect { |row| self.new_from_db(row) }.first
    end

    def find_or_create_by(arguments)
      dog_data = DB[:conn].execute(
          "SELECT id, name, breed FROM #{TABLE_NAME} WHERE name = ? AND breed = ?",
                                          arguments[:name], arguments[:breed])
      if dog_data.empty?
        dog = self.create(arguments)
      else
        dog = Dog.new({id: dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2]})
      end
      return dog
    end

    def find_by_name(name)
      sql = "SELECT id, name, breed FROM #{TABLE_NAME} WHERE name = ? LIMIT 1"
      return DB[:conn].execute(sql,name).collect { |row| self.new_from_db(row) }.first
    end

  end

  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each { |key, value| self.send(("#{key}="), value) }
    return self
  end

  def save()
    if self.id.nil?
      sql = "INSERT INTO #{TABLE_NAME} (name, breed) VALUES (?, ?)"

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{TABLE_NAME}")[0][0]
    else
      self.update
    end

    return self
  end

  def update()
    sql = "UPDATE #{TABLE_NAME} SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
