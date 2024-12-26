

class FakeAppIo

  attr_accessor :archive_content, :console_output_content
  attr_accessor :console_input_content, :tasks_content
  attr_accessor :update_content, :today_content
  attr_accessor :log_content

  def initialize
    @archive_content = @tasks_content = ""
    @console_output_content = ""
    @log_content = ""
    @update_content = []
  end

  def read_archive
    @archive_content
  end

  def write_archive archive_entries
    @archive_content = archive_entries.join
  end

  def read_log
    @log_content
  end

  def write_log text
    @log_content = text
  end

  def append_to_log line
  end

  def append_to_archive text
    @archive_content = @archive_content + text
  end

  def append_to_junk text
  end

  def read_tasks
    @tasks_content
  end

  def write_tasks tasks
    @tasks_content = tasks.join
  end

  def read_updates
    @update_content
  end

  def write_updates updates
    @update_content = updates
  end

  def append_to_console text
    @console_output_content = @console_output_content + text
  end

  def get_from_console
    text = @console_input_content
    @console_input_content = ""
    text
  end

  def clear_console
  end

  def today
    @today_content
  end

  def renderer
    NullRenderer.new
  end

end
