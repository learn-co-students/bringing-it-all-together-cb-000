class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
  end

  def self.create_table
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save

=begin
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
=end
  end

  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      LIMIT 1
      SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first

  end

end
