require 'spec_helper'
require 'session'
require 'commands/zap_to_position'
require 'commands/cursor_set'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe ZapToPosition do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }

  it 'zaps the item at zero to one' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output = [[0, "-", "L: second\n"], [1, " ", "L: first\n"]]
    ZapToPosition.new.run("z 1", session)
  
    expect(o).to eq(output)
  end

  it 'saturates when asked to zap outside the range high' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    ZapToPosition.new.run("z 2", session)
    output = [[0, "-", "L: second\n"], [1, " ", "L: first\n"]]
    
    expect(o).to eq(output)
  end

  it 'saturates when asked to zap outside the range low' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output = [[0," ", "L: second\n"], [1, "-", "L: first\n"]]
    CursorSet.new.run("c 1", session)
    ZapToPosition.new.run("z -1", session)
    
    expect(o).to eq(output)
  end

  it 'noops when asked to zap to the same position' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output = [[0,"-", "L: first\n"], [1, " ", "L: second\n"]]
    ZapToPosition.new.run("z 0", session)

    expect(o).to eq(output)
  end

  it 'has insertion rather than swap aemantics' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output =  [[0, "-", "L: second\n"],[1, " ", "L: third\n"], [2, " ", "L: first\n"]]
    ZapToPosition.new.run("z 2", session)

    expect(o).to eq(output)
  end
end