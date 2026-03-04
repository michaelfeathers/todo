require 'spec_helper'
require 'session'
require 'commands/down'
require 'commands/cursor_set'
require 'fakeappio'
require 'interactive_paginator'


describe Down do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

  it 'pages when cursor set off page' do
    page_size = InteractivePaginator::PAGE_SIZE
    visual_pos = page_size - 1

    tasks     =  50.times.map {|n| "L: task #{n}\n" }
    # After "c 39" (visual label 39 = flat index 39), then down moves to flat 40 (visual 40)
    expected  =  50.times.map {|n| [n.to_s,(n == (visual_pos + 1) ? "-" : " "), "L: task #{n}\n"] }

    f_io.tasks_content = tasks.join

    CursorSet.new.run("c #{visual_pos}", session)
    Down.new.run("d", session)

    expect(o).to eq(expected.drop(page_size).take(page_size))
  end
end
