require_relative "../config/environment.rb"

class Dog
  # has a name and a breed
  attr_accessor :name, :breed, :id

  # has an id that defaults to `nil` on initialization
  # accepts key value pairs as arguments to initialize
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

end
