require 'spec_helper'
require 'session'
require 'commands/up'
require 'fakeappio'


describe Up do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE - 1
    tasks  =  50.times.map {|n| "L: task #{n}\n" }
    output =  50.times.map {|n| "%2d %s L: task %d\n" % [n,n == pos ? "-" : " " ,n] }
    f_io.tasks_content = tasks.join
    ToDoPageDown.new.run("dd", session)
    CursorSet.new.run("c #{pos}", session)
    Up.new.run("d", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end
end
