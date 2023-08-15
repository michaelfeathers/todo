$:.unshift File.dirname(__FILE__)

require 'date'

ROOT_DIR     = "/Users/michaelfeathers/Projects/todo/lib/"
TODO_FILE    = ROOT_DIR + "todo.txt"
UPDATER_FILE = ROOT_DIR + "updates.txt"
ARCHIVE_FILE = ROOT_DIR + "archive.txt"
VIEW_LIMIT   = 45

CLEAR_SCREEN =  "\e[H\e[2J" 


class Array
  def swap_elements i, j
    e = self[i]; self[i] = self[j]; self[j] = e
    self
  end
end

def month_name_of month_no
  DateTime.parse("2023-#{month_no}-01").strftime("%b")
end

def day_date dt
  DateTime.new(dt.year, dt.month, dt.day, 0, 0, 0, dt.zone)
end


class Session

  def todo_add tokens
    @actions = [tokens.join(" ") + $/] + @actions
    @cursor = 0
  end

  def todo_quit
    File.open(TODO_FILE, 'w') { |f| f.write(@actions.join) }
    exit
  end

  def todo_cursor_set line_no
    @cursor = line_no if (0...@actions.count).include?(line_no)
    # should this saturate?
  end

  def todo_down
    return unless @actions.count > 1 
    return unless @cursor < @actions.count - 1
    
    @actions.swap_elements(@cursor, @cursor + 1) if @grab_mode
    @cursor += 1
  end

  def todo_up
    return unless @actions.count > 1
    return unless @cursor > 0

    @actions.swap_elements(@cursor - 1, @cursor) if @grab_mode
    @cursor -= 1
  end

  def todo_find text
    puts CLEAR_SCREEN 
    found = @actions.each_with_index.map {|i,e| "%2d %s" % [e,i] }.grep(Regexp.new(text))
    puts found.join + $/ + found.count.to_s + $/ + $/
  end
  
  def todo_push days_text
    updates = File.read(UPDATER_FILE).lines.to_a
    date_text = DateTime.now.next_day(days_text.to_i).to_s[0, 10] 

    updates << [date_text, @actions[@cursor]].join(' ')
    updates = updates.sort_by {|line| DateTime.parse(line.split.first) }

    File.open(UPDATER_FILE, 'w') { |f| f.write(updates.join) }
    todo_remove
  end

  def todo_remove
    @actions.delete_at(@cursor)
    @cursor = [@cursor, @actions.count - 1].min
  end

  def todo_save
    File.open(ARCHIVE_FILE, 'a') { |f| f.write(DateTime.now.to_s[0, 10] + " " + @actions[@cursor]) }
    todo_remove
  end

  def todo_save_no_remove
    File.open(ARCHIVE_FILE, 'a') { |f| f.write(DateTime.now.to_s[0, 10] + " " + @actions[@cursor]) }
  end

  def todo_edit tokens
    @actions[@cursor] = tokens.join(" ") + $/
  end

  def todo_grab_toggle
    @grab_mode = (not @grab_mode)
  end
  
  def todo_month_summaries
    task_descs = File.read(ARCHIVE_FILE)
                      .lines
                      .map {|l| [DateTime.parse(l.split[0]), l.split[1].chars.first] }

   year_descs =  task_descs.select {|td| td.first.year == 2023 }
   puts "\n\n      %10s %10s %10s %10s" % ["R7K", "Globant", "Life", "Total"]
   puts ""
   (1..12).each do |month|
     puts "%s   %10d %10d %10d %10d" % [month_name_of(month), 
                                  year_descs.select {|d| d.first.month == month }.select {|dd| dd[1] == "R" }.count,
                                  year_descs.select {|d| d.first.month == month }.select {|dd| dd[1] == "G" }.count,       
                                  year_descs.select {|d| d.first.month == month }.select {|dd| dd[1] == "L" }.count,
                                  year_descs.select {|d| d.first.month == month }.count]

   end
   puts ""
   puts "      %10d %10d %10d %10d" % [year_descs.select {|dd| dd[1] == "R" }.count,
                                       year_descs.select {|dd| dd[1] == "G" }.count,
                                       year_descs.select {|dd| dd[1] == "L" }.count,
                                       year_descs.count]

   puts ""

   todays = year_descs.select {|d| day_date(d.first) === day_date(DateTime.now) } 


   if todays.count > 0
     puts "Today %10d %10d %10d %10d" % [todays.select {|d| d[1] == "R" }.count,
                                         todays.select {|d| d[1] == "G" }.count,
                                         todays.select {|d| d[1] == "L" }.count,
                                         todays.count]
   else
     puts "Today %10d %10d %10d %10d" % [0, 0, 0, 0]
   end

   puts ""
   puts ""

   gets
  end

  def initialize
    @cursor = 0
    @grab_mode = false
    @actions = File.read(TODO_FILE).lines
    render
  end

  def cursor_char index
    return " " unless @cursor == index
    @grab_mode ? "*" : "-"
  end

  def render
    puts CLEAR_SCREEN 
    index = 0
    @actions.each do |e|
      print ("%2d %s %s" % [index, cursor_char(index), e]) 
      break if index >= VIEW_LIMIT
      index = index + 1
    end
    print ("\n%s\n\n" % [index >= VIEW_LIMIT ? "..." : ""])

    # @actions.each_with_index {|e,i| print ("%2d %s %s" % [i, cursor_char(i), e]) }
    # puts ""
  end
end




