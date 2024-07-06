require 'spec_helper'
require 'session'
require 'commands'
require 'fakeappio'


describe Session do

  before(:each) do
    @io = FakeAppIo.new
    @session = Session.from_ios(@io, @io)
  end

  it 'updates the existing command log' do
    @io.log_content = "c,12\nz,10"
    @session = Session.from_ios(@io, @io)
    @session.log_command("z")
    expect(@io.log_content).to eq("c,12\nz,11")
  end

  it 'adds to existing command log' do
    @io.log_content = "c,12\nz,10\n"
    @session = Session.from_ios(@io, @io)
    @session.log_command("t")
    expect(@io.log_content).to eq("c,12\nz,10\nt,1")
  end

  it 'adds to an empty command log' do
    @io.log_content = ""
    @session = Session.from_ios(@io, @io)
    @session.log_command("t")
    expect(@io.log_content).to eq("t,1")
  end

end


describe 'Session#surface' do
  before(:each) do
    @foreground_io = FakeAppIo.new
    @background_io = FakeAppIo.new
  end

  it 'does nothing if background list is empty' do
    expect(@foreground_io).to receive(:append_to_actions).never
    @session = Session.from_ios(@foreground_io, @background_io)
    @session.surface(3)
    @session.save
  end

  it 'moves the specified number of random tasks from background to foreground' do
    @background_io.actions_content = "Task 1\nTask 2\nTask 3"
    @session = Session.from_ios(@foreground_io, @background_io)

    @session.surface(2)
    @session.save

    expect(@foreground_io.actions_content.split("\n").size).to eq(2)
    expect(@background_io.actions_content.split("\n").size).to eq(1)
  end

  it 'moves all tasks from background to foreground if count exceeds background size' do
    @background_io.actions_content = "Task 1\nTask 2"
    @session = Session.from_ios(@foreground_io, @background_io)
    @session.surface(5)
    @session.save

    expect(@foreground_io.actions_content.split("\n").size).to eq(2)
    expect(@background_io.actions_content).to eq("")
  end
end
