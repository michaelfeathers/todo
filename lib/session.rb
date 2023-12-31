$:.unshift File.dirname(__FILE__)

require 'appio'
require 'tasklist'


class Session

  attr_reader :list


  def initialize foreground_io, background_io
    @foreground_io = foreground_io
    @background_io = background_io
    @list = TaskList.new(@foreground_io)
  end

  def switch_lists 
    return unless @background_io
    @list = TaskList.new(@background_io)
  end

end



