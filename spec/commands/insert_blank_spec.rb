require 'spec_helper'
require 'commands/insert_blank'
require 'session'
require 'fakeappio'


describe InsertBlank do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'inserts a blank line at the current cursor position' do
    f_io.tasks_content = "L: task AA\nL: task BB\n"
    session.list.cursor_set(0)

    InsertBlank.new.run("i", session)
    session.render

    expect(f_io.console_output_content).to eq("\n\n 0 - \n 1   L: task AA\n 2   L: task BB\n\n")
  end

  it 'inserts a blank line and maintains the cursor position on the same task' do
    f_io.tasks_content = "L: task AA\nL: task BB\n"
    session.list.cursor_set(0)

    InsertBlank.new.run("i", session)
    session.list.down

    expect(session.list.task_at_cursor).to eq("L: task AA") # Cursor should now
  end
end
