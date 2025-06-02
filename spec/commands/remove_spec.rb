require 'spec_helper'
require 'session'
require 'commands/remove'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe Remove do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }

  it 'removes an task' do
    f_io.tasks_content = "L: task AA\nL: task BB\n"
    f_io.console_input_content = "Y"
    Remove.new.run("r", session)
    expect(f_io.tasks_content).to eq("L: task BB\n")
  end
end