require_relative '../command'
require_relative '../session'
require_relative '../appio'
require_relative '../day'
require_relative '../array_ext'
require 'gruff'

class TrendChart < Command
  def matches? line
    (line.split in ["tc", *args]) && args.count <= 1
  end

  def process line, session
    opt_year = line.split[1] if line.split.count == 2

    session.on_list do |list|
      io = list.io
      day_frequencies = calculate_day_frequencies(io, opt_year)

      g = Gruff::Line.new(1600)
      g.theme = {
        colors: %w[red],
        marker_color: 'gray',
        font_color: 'black',
        background_colors: 'white'
      }
      g.data('', day_frequencies.map {|e| e[1] })
      g.write('trend.png')
      `open trend.png`
    end
  end

  def description
    CommandDesc.new("tc", "show trend chart")
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