$:.unshift File.dirname(__FILE__)



class FakeAppIo
  attr_accessor :archive_content, :console_content, :actions_content

  def initialize
    @archive_content = @console_content = @actions_content = ""
  end

  def read_archive
    @archive_content
  end

  def read_actions
    @actions_content
  end

  def append_to_console text
    @console_content = @console_content + text + $/
  end

  def get_from_console
    ""
  end
end

