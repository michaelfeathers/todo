require_relative '../command'
require_relative '../session'
require_relative '../appio'

class TagTallies < Command
  def matches? line
    line.split == ["tt"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      mask = "   %-10s%3d"
      tagged = list.tag_tallies.map {|t, n| mask % [t, n] }.join($/)
      untagged = mask % ["Untagged", list.untagged_tally]

      io.append_to_console $/ + $/ + "#{tagged}\n\n#{untagged}" + $/ + $/
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("tt", "show tally of all tag types")
  end
end