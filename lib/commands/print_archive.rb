require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../date_toggle_formatter'

class PrintArchive < Command
  include DateToggleFormatter

  def matches?(line)
    line.split == ["pa"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      formatted_archive = format_with_date_toggle(io.read_archive)
      io.display_paginated(formatted_archive)
    end
  end

  def description
    CommandDesc.new("pa", "print the archive")
  end
end