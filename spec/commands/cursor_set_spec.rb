require 'spec_helper'
require 'session'
require 'commands/cursor_set'
require 'fakeappio'
require 'testrenderer'
require 'interactive_paginator'

def rendering_of session
  target = TestRenderer.new
  session.render(target)

  target.rendered_data
end

describe CursorSet do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }


  it 'pages when cursor set off page' do
    page_size          = InteractivePaginator::PAGE_SIZE
    pos                = page_size + 5

    tasks              =  50.times.map {|n| "L: task #{n}\n" }
    expected           =  50.times.map {|n| [n,n == pos ? "-" : " " , "L: task #{n}\n"] }
    f_io.tasks_content =  tasks.join

    CursorSet.new.run("c #{pos}", session)

    expect(o).to eq(expected.drop(page_size).take(page_size))
  end
end
