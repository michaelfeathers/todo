$:.unshift File.dirname(__FILE__)

require 'session'
require 'commands'
require 'fakeappio'

describe ToDoRemove do

  let(:io) { FakeAppIo.new }
  let(:session) { Session.new(io) }

  it 'removes an action' do
    io.actions_content = "L: task AA\nL: task BB\n"
    io.console_input_content = "Y"
    ToDoRemove.new.run("r", session)
    expect(io.actions_content).to eq("L: task BB\n")
  end
end


def cursor_char index
  return "-" if index == 0
  " "
end

describe ToDoPageDown do
  let(:io) { FakeAppIo.new }
  let(:session) { Session.new(io) }

  it 'shows the first page of tasks' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    io.actions_content = actions.join 
    session.render
    expect(io.console_output_content).to eq(output.take(45).join + "\n")
  end

  it 'shows the second page of tasks' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    io.actions_content = actions.join 
    ToDoPageDown.new.run("dd", session)
    session.render
    expect(io.console_output_content).to eq(output.drop(40).take(45).join + "\n")
  end
end


class ToDoPageUp; end

describe ToDoPageUp do

  let(:io) { FakeAppIo.new }
  let(:session) { Session.new(io) }

  xit 'shows the first page of tasks' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    io.actions_content = actions.join 
    ToDoPageUp.new.run("uu", session)
    session.render
    expect(io.console_output_content).to eq(output.take(45).join + "\n")
  end

  xit 'shows the first page of tasks after previously paging down' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    io.actions_content = actions.join 
    ToDoPageDown.new.run("dd", session)
    ToDoPageUp.new.run("uu", session)
    session.render
    expect(io.console_output_content).to eq(output.take(45).join + "\n")
  end

  
end






