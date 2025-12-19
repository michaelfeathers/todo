# Auto-loads all command files from the commands directory
require_relative 'command'

Dir[File.join(__dir__, 'commands', '*.rb')].sort.each { |file| require file }