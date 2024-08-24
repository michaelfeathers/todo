require 'spec_helper'
require 'session'
require 'commands/down'
require 'fakeappio'


describe Down do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE  - 1
    tasks  =  50.times.map {|n| "L: task #{n}\n" }
    output =  50.times.map {|n| "%2d %s L: task %d\n" % [n,n == (pos + 1) ? "-" : " " ,n] }
    f_io.tasks_content = tasks.join
    CursorSet.new.run("c #{pos}", session)
    Down.new.run("d", session)
    session.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end
end
