require 'spec_helper'
require 'session'
require 'commands/zap_to_top'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe ZapToTop do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'moves the task at the cursor to position 0' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n",
      "L: task 3\n",
      "L: task 4\n"
    ]

    output = [
      [0, " ", "L: task 2\n"],
      [1, " ", "L: task 0\n"],
      [2, "-", "L: task 1\n"],
      [3, " ", "L: task 3\n"],
      [4, " ", "L: task 4\n"]
    ]

    f_io.tasks_content = tasks.join
    session.list.cursor_set(2)
    ZapToTop.new.run("zz", session)

    expect(o).to eq(output)
  end

  it 'does nothing when the cursor is already at position 0' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n",
      "L: task 3\n",
      "L: task 4\n"
    ]
    
    output = [
      [0, "-", "L: task 0\n"],
      [1, " ", "L: task 1\n"],
      [2, " ", "L: task 2\n"],
      [3, " ", "L: task 3\n"],
      [4, " ", "L: task 4\n"]
    ]

    f_io.tasks_content = tasks.join
    session.list.cursor_set(0)
    ZapToTop.new.run("zz", session)

    expect(o).to eq(output)
  end
end