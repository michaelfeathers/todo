class Position
  attr_reader :top, :child

  def self.top(top)          = new(top, nil)
  def self.child(top, child) = new(top, child)

  def initialize(top, child = nil)
    @top, @child = top, child
  end

  def top_level? = @child.nil?
  def child?     = !@child.nil?

  # the Task / Section / child-Task this position points at, or nil if out of range
  def resolve(items)
    return nil if @top >= items.size
    top_level? ? items[@top] : items[@top].children[@child]
  end

  def on_section_header?(items)
    top_level? && !!items[@top]&.section?
  end

  def label
    top_level? ? @top.to_s : "#{@top}.#{@child + 1}"
  end

  def ==(other)
    other.is_a?(Position) && other.top == @top && other.child == @child
  end
  alias eql? ==

  def hash = [@top, @child].hash
end
