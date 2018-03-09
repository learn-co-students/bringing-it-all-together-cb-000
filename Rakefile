require_relative 'config/environment'
require 'Pry'

task :console do
  def reload!
    load_all './lib'
  end

  Pry.start
end
