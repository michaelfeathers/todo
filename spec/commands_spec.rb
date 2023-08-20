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


describe ToDoPageDown do
  let(:io) { FakeAppIo.new }
  let(:session) { Session.new(io) }

  it 'shows the first page of tasks' do
    tasks = 50.times.map {|n| "L: task #{n}\n" }
    io.actions_content = tasks.join 
    ToDoPageDown.new.run("dd", session)
    session.render
    expect(io.console_output_content).to eq(tasks.take(46).join + "\n...\n\n")
  end
end






