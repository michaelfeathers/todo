$:.unshift File.dirname(__FILE__)

require 'appio'
require 'tasklist'


class Session

  attr_reader :list

  def initialize io
    @io = io
    @list = TaskList.new(io)
  end

end



