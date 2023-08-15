

FNAME = "/Users/michaelfeathers/Projects/todo/lib/archive.txt"

class Array
  def freq
    group_by {|e| e }.map {|k,v| [k, v.count] }.sort_by(&:first)
  end
end


puts "day, count"
File.read(FNAME)
    .lines
    .map {|line| line.split[0] }
    .freq
    .each {|e| puts "%s, %s" % [e[0], e[1]] }

