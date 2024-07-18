require 'spec_helper'
require 'session'
require 'commands/cursor_to_start'
require 'fakeappio'

describe CursorToStart do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'moves the cursor to the 0th task when not already there' do
    actions = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    output = actions.map.with_index do |action, i|
      cursor = i.zero? ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]
    end.join

    f_io.actions_content = actions.join
    session.list.cursor_set(2)
    CursorToStart.new.run("cc", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'does nothing when cursor is already at 0th task' do
    actions = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    output = actions.map.with_index do |action, i|
      cursor = i.zero? ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]
    end.join

    f_io.actions_content = actions.join
    session.list.render
    CursorToStart.new.run("cc", session)

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end
end
