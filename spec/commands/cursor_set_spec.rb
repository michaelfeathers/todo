require 'spec_helper'
require 'session'
require 'commands/cursor_set'
require 'fakeappio'
require 'testrenderer'


describe CursorSet do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }


  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE + 5
    tasks   =  50.times.map {|n| "L: task #{n}\n" }
    expected_output  =  50.times.map {|n| [n,n == pos ? "-" : " " , "L: task #{n}\n"] }
    f_io.tasks_content = tasks.join
    CursorSet.new.run("c #{pos}", session)
    # output = session.on_list {|list| list.window }
    test_target = TestRenderer.new
    session.render(test_target)
    output = test_target.rendered_data

    expect(output).to eq(expected_output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE))
  end
end
