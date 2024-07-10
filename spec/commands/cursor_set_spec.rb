require 'spec_helper'
require 'session'
require 'commands/cursor_set'
require 'fakeappio'

RENDER_PAD = "\n\n"


describe CursorSet do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }


  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE + 5
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,n == pos ? "-" : " " ,n] }
    f_io.actions_content = actions.join
    CursorSet.new.run("c #{pos}", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end
end
