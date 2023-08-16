$:.unshift File.dirname(__FILE__)

require 'common'


class AppIo
  def read_archive
    File.read(ARCHIVE_FILE)
  end
end
