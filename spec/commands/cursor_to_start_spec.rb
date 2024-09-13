require 'spec_helper'
require 'session'
require 'commands/cursor_to_start'
require 'fakeappio'


describe CursorToStart do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'moves the cursor to the 0th task when not already there' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    output = tasks.map.with_index do |task, i|
      cursor = i.zero? ? '-' : ' '
      "%2d %s %s" % [i, cursor, task]
    end.join

    f_io.tasks_content = tasks.join
    session.list.cursor_set(2)
    CursorToStart.new.run("cc", session)
    session.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'does nothing when cursor is already at 0th task' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    output = tasks.map.with_index do |task, i|
      cursor = i.zero? ? '-' : ' '
      "%2d %s %s" % [i, cursor, task]
    end.join

    f_io.tasks_content = tasks.join
    session.render
    CursorToStart.new.run("cc", session)

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end
end
