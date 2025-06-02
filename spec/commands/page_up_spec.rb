require 'spec_helper'
require 'session'
require 'commands/page_up'
require 'commands/page_down'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

def cursor_char index
  return "-" if index == 0
  " "
end

describe PageUp do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }


  it 'shows the first page of tasks' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| [n,cursor_char(n),"L: task #{n}\n"] }
    
    f_io.tasks_content = tasks.join
    PageUp.new.run("uu", session)

    expect(o).to eq(output.take(TaskList::PAGE_SIZE))
  end

  it 'shows the first page of tasks after previously paging down' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| [n,cursor_char(n),"L: task #{n}\n"] }
    f_io.tasks_content = tasks.join
    PageDown.new.run("dd", session)
    PageUp.new.run("uu", session)
   
    expect(o).to eq(output.take(TaskList::PAGE_SIZE))
  end     
end