$:.unshift File.dirname(__FILE__)

require 'common'


class AppIo
  def read_archive
    File.read(ARCHIVE_FILE)
  end

  def append_to_console text
    puts text 
  end

  def get_from_console
    gets
  end
end
