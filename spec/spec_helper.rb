require 'rubygems'
require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/' # Exclude spec files from coverage
  add_filter '/lib/appio.rb'
end

Dir[File.expand_path('../lib/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  # Additional RSpec configuration can go here
end
