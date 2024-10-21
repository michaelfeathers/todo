require 'spec_helper'
require 'session'
require 'commands/cursor_to_start'
require 'fakeappio'


describe CursorToStart do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'moves the cursor to the 0th task when not already there' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    expected = tasks.map.with_index do |task, i|
      [i, i.zero? ? '-' : ' ', task]
    end

    f_io.tasks_content = tasks.join
    session.list.cursor_set(2)
    CursorToStart.new.run("cc", session)

    expect(o).to eq(expected)
  end

  it 'does nothing when cursor is already at 0th task' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    expected = tasks.map.with_index do |task, i|
      [i, i.zero? ? '-' : ' ', task]
    end

    f_io.tasks_content = tasks.join
    CursorToStart.new.run("cc", session)

    expect(o).to eq(expected)
  end
  
end
