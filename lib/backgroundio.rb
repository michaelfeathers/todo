require_relative "appio.rb"

BACKGROUND_FILE = ROOT_DIR + "background_todo.txt"


class BackgroundIo < AppIo

  def read_tasks
    File.read(BACKGROUND_FILE)
  end

  def write_tasks tasks
    File.open(BACKGROUND_FILE, 'w') { |f| f.write(tasks.join) }
  end

end
