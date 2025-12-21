require_relative '../command'
require_relative '../session'
require_relative '../appio'

class ShowCommandFrequencies < Command
  def matches? line
    line.split == ["sf"]
  end

  def process line, session
    session.on_list do |list|
      io = list.io
      data = io.read_log
                .split
                .map{|line| line.split(',') }
                .map{|name,count| [name, count.to_i] }

      total = data.sum {|_,count| count }

      results = data.map {|name, count| "%-5.2f  %-4d   %s" % [count * 100.0 / total, count, name]}
                    .join($/)

      io.append_to_console $/ + results + $/ + $/
      io.get_from_console
    end
  end

  def description
    CommandDesc.new("sf ", "show command frequencies")
  end
end