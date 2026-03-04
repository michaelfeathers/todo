require_relative 'task'

class Section < Task
  attr_reader :children
  attr_accessor :name

  def initialize(name)
    @name = name
    @children = []
    super("#0 #{name}\n")
    @collapsed = true
  end

  def section?
    true
  end

  def add(task)
    @children << task
    update_text
  end

  def remove(index)
    removed = @children.delete_at(index)
    update_text
    removed
  end

  def insert(index, task)
    @children.insert(index, task)
    update_text
  end

  def count
    @children.size
  end

  private

  def update_text
    @text = "##{@children.size} #{@name}\n"
  end
end
