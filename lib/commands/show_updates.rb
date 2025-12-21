require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../date_toggle_formatter'

class ShowUpdates < Command
  include DateToggleFormatter

  def matches? line
    line.split == ["pp"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      formatted_updates = format_with_date_toggle(io.read_updates)
      io.display_paginated(formatted_updates)
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("pp", "show updates")
  end
end