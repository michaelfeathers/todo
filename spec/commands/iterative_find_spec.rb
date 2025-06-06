require 'spec_helper'
require 'commands/iterative_find'
require 'session'
require 'fakeappio'
require 'testrenderer'


describe IterativeFind do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of (session) }

  it 'finds the token and moves the cursor to the line where it is first found' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2 with token\n",
      "L: task 3 with token\n",
      "L: task 4\n"
    ]
    expected = tasks.map.with_index do |task, i|
      cursor = i == 2 ? '-' : ' '
      [i, cursor, task]
    end

    f_io.tasks_content = tasks.join
    session.on_list {|list| list.cursor_set(1) }
    IterativeFind.new.run("ff token", session)

    expect(o).to eq(expected)
  end

  it 'does not change the cursor position if the token is not found' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n",
      "L: task 3\n",
      "L: task 4\n"
    ]

    expected = tasks.map.with_index do |task, i|
      cursor = i == 1 ? '-' : ' '
      [i, cursor, task]
    end

    f_io.tasks_content = tasks.join

    session.on_list {|list| list.cursor_set(1) }
    IterativeFind.new.run("ff token", session)

    expect(o).to eq(expected)
  end

  it 'finds the token from the next line after the cursor when no text is provided' do
    tasks = [
      "L: task 0\n",
      "L: task 1 with token\n",
      "L: task 2\n",
      "L: task 3 with token\n",
      "L: task 4\n"
    ]
  
    expected = tasks.map.with_index do |task, i|
      cursor = i == 3 ? '-' : ' '
      [i, cursor, task]
    end

    f_io.tasks_content = tasks.join

    session.on_list {|list| list.cursor_set(1) }
    IterativeFind.new.run("ff token", session)
    IterativeFind.new.run("ff", session)

    expect(o).to eq(expected)
  end
end
