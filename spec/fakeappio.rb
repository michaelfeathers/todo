$:.unshift File.dirname(__FILE__)



class FakeAppIo
  attr_accessor :archive_content, :console_content, :actions_content
  attr_accessor :today_content

  def initialize
    @archive_content = @console_content = @actions_content = ""
    @today_day = nil
  end

  def read_archive
    @archive_content
  end

  def read_actions
    @actions_content
  end

  def append_to_console text
    @console_content = @console_content + text 
  end

  def get_from_console
    ""
  end

  def clear_console
  end

  def today
    @today_content
  end
end

