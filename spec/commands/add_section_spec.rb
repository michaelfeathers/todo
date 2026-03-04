require 'spec_helper'
require 'session'
require 'commands/add_section'
require 'fakeappio'
require 'testrenderer'

describe AddSection do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'adds a section header at the top of the list' do
    f_io.tasks_content = "L: task 1\n"
    AddSection.new.run("as Work", session)

    session.save
    expect(f_io.tasks_content).to eq("#0 Work\nL: task 1\n")
  end

  it 'adds a multi-word section header' do
    f_io.tasks_content = "L: task 1\n"
    AddSection.new.run("as Work Projects", session)

    session.save
    expect(f_io.tasks_content).to eq("#0 Work Projects\nL: task 1\n")
  end

  it 'sets cursor to zero after adding' do
    f_io.tasks_content = "L: task 1\n"
    AddSection.new.run("as Work", session)

    expect(session.list.task_at_cursor).to eq("#0 Work")
  end
end
