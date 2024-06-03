require 'simplecov'

SimpleCov.start do
  add_filter '/spec/' # Exclude spec files from coverage
  add_filter '/lib/appio.rb' 
end

RSpec.configure do |config|
  # Additional RSpec configuration can go here
end

