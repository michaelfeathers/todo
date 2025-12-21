require_relative '../command'
require_relative '../session'
require_relative '../appio'

class ShowUpdates < Command
  def matches? line
    line.split == ["pp"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      io.display_paginated(io.read_updates)
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("pp", "show updates")
  end
end