require 'spec_helper'
require 'session'
require 'commands/save_actions'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe SaveActions do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'saves the tasks without quitting' do
    tasks_content = "L: task 1\nL: task 2\n"
    f_io.tasks_content = tasks_content

    SaveActions.new.run("@", session)

    expect(f_io.tasks_content).to eq(tasks_content)
  end
end