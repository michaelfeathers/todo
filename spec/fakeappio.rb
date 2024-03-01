$:.unshift File.dirname(__FILE__)



class FakeAppIo
  attr_accessor :archive_content, :console_output_content 
  attr_accessor :console_input_content, :actions_content
  attr_accessor :update_content, :today_content

  def initialize
    @archive_content = @actions_content = ""
    @console_output_content = "" 
    @update_content = []
    @today_day = nil
  end

  def read_archive
    @archive_content
  end

  def append_to_archive text
    @archive_content = @archive_content + text
  end

  def append_to_junk text
  end

  def read_actions
    @actions_content
  end

  def write_actions actions
    @actions_content = actions.join
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

  def suppress_render_list
    false
  end
end

