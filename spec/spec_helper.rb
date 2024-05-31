require 'simplecov'
SimpleCov.start do
  add_filter '/spec/' # Exclude spec files from coverage
end

RSpec.configure do |config|
  # Additional RSpec configuration can go here
end

