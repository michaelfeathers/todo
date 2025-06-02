require 'spec_helper'
require 'session'
require 'commands/retag'
require 'commands/cursor_set'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe Retag do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'retags an L to an R' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output = [[0, " ", "L: first\n"],[1, "-", "R: second\n"], [2, " ", "L: third\n"]]

    CursorSet.new.run("c 1", session)
    Retag.new.run("rt r", session)

    expect(o).to eq(output)
  end

  it'does nothing when regtagging in an empty task list' do
    f_io.tasks_content = ""
    output =  []
    Retag.new.run("rt r", session)

    expect(o).to eq([])
   end

   it 'adds a tag to a task with no tag' do
     f_io.tasks_content = "L: first\n"
     output =  [[0, "-", "L: first\n"]]

     Retag.new.run("rt l", session)

    expect(o).to eq(output)
   end
end