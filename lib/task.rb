class Task
  attr_accessor :text, :collapsed

  def initialize(text)
    @text = text
    @collapsed = false
  end

  def section?
    false
  end
end
