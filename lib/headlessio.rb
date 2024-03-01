
$:.unshift File.dirname(__FILE__)

class HeadlessIo < AppIo

  def initialize
    @done = false
  end

  def get_from_console
    if not @done 
      @done = true
      return ARGV.join(' ') + $/  
    else 
      return "q" + $/
    end
  end

  def clear_console
  end

  def suppress_render_list
    true
  end
end

