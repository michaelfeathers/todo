require 'spec_helper'
require 'session'
require 'commands/switch_lists'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe SwitchLists do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'switches away foreground' do
     f_io.tasks_content = [ 
      "L: first\n", 
      "L: second\n",
      "L: third\n"
    ].join

     output = [
      [0, "-", "L: first\n"],
      [1, " ", "L: second\n"],
      [2, " ", "L: third\n"],
    ]

    expect(o).to eq(output)

    SwitchLists.new.run("w", session)

    expect(rendering_of(session)).to eq([])
  end

  it 'switches foreground and background' do
     f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     b_io.tasks_content = [ "R: first\n", "R: second\n",  "R: third\n"].join

    output_before = [ 
      [0, "-", "L: first\n"],
      [1, " ", "L: second\n"],
      [2, " ", "L: third\n"]
    ]

    output_after  = [ 
      [0, "-", "R: first\n"],
      [1, " ", "R: second\n"],
      [2, " ", "R: third\n"]
    ]

    expect(o).to eq(output_before)

    SwitchLists.new.run("w", session)

    expect(rendering_of(session)).to eq(output_after)
  end

  it 'switches to the background list and moves the cursor to the specified position' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    b_io.tasks_content = [ "R: first\n", "R: second\n",  "R: third\n"].join

    output_after  = [ 
      [0, " ", "R: first\n"],
      [1, "-", "R: second\n"],
      [2, " ", "R: third\n"]
    ]

    SwitchLists.new.run("w 1", session)

    expect(o).to eq(output_after)
  end

  it 'does not change the cursor position if no position is specified' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    b_io.tasks_content = [ "R: first\n", "R: second\n",  "R: third\n"].join

    output_after  = [ 
      [0, "-", "R: first\n"],
      [1, " ", "R: second\n"],
      [2, " ", "R: third\n"]
    ]

    SwitchLists.new.run("w", session)

    output_after  = [ 
      [0, "-", "R: first\n"],
      [1, " ", "R: second\n"],
      [2, " ", "R: third\n"]
    ]

    expect(o).to eq(output_after)
  end
end