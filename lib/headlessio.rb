

class HeadlessIo < AppIo

  def initialize
    @done = false
  end

  def get_from_console
    @done ? "q\n" : (@done = true; ARGV.join(' ') + "\n")
  end

  def clear_console
  end

  def renderer
    NullRenderer.new
  end

end
