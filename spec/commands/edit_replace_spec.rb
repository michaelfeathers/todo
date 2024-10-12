require 'spec_helper'
require 'session'
require 'commands/edit_replace'
require 'fakeappio'


describe EditReplace do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'replaces when text to replacement is present' do
    f_io.tasks_content = "L: task AA\nL: task BB\n"
    session.list.cursor_set(1)

    EditReplace.new.run("er 2 bb", session)
    session.render_naked

    expect(f_io.console_output_content).to eq("\n\n 0   L: task AA\n 1 - L: task bb\n\n")
  end

  it 'replaces multiple tokens' do
    f_io.tasks_content = "L: old task here\n"
    session.list.cursor_set(0)

    EditReplace.new.run("er 2 new task there", session)
    session.render_naked

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new task there\n\n")
  end

  it 'replaces tokens until replacements run out' do
    f_io.tasks_content = "L: old old old task\n"
    session.list.cursor_set(0)

    EditReplace.new.run("er 2 new new", session)
    session.render_naked

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new new task\n\n")
  end

  it 'replaces tokens past the end of the original line' do
    f_io.tasks_content = "L: old old old\n"
    session.list.cursor_set(0)

    EditReplace.new.run("er 2 new new new", session)
    session.render_naked

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new new new\n\n")
  end

  it 'deletes token at position when no replacement provided' do
    f_io.tasks_content = "L: this is a task\n"
    session.list.cursor_set(0)

    EditReplace.new.run("er 2", session)
    session.render_naked

    expect(f_io.console_output_content).to eq("\n\n 0 - L: this a task\n\n")
  end
end
