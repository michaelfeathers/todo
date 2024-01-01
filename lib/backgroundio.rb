$:.unshift File.dirname(__FILE__)

require "appio.rb"

BACKGROUND_FILE    = ROOT_DIR + "background_todo.txt"

class BackgroundIo < AppIo

  def read_actions
    File.read(BACKGROUND_FILE)
  end
  
  def write_actions actions
    File.open(BACKGROUND_FILE, 'w') { |f| f.write(actions.join) }
  end

end
