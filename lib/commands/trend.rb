require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../day'
require_relative '../array_ext'

class Trend < Command
  def matches? line
    line.split == ["tr"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      day_frequencies = calculate_day_frequencies(io, nil)

      day_frequencies.each {|e| io.append_to_console(("%3s  %s" %  [e[1], e[0]]) + $/) }
      io.append_to_console($/)
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("tr", "show trend")
  end

  private

  def calculate_day_frequencies(io, year)
    io.read_archive
       .lines
       .map {|line| line.split.first }
       .select {|d| !year || Day.from_text(d).year ==  year }
       .freq
  end
end