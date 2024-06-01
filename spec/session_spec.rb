
require 'spec_helper'
require 'session'
require 'commands'
require 'fakeappio'

describe Session do

  before(:each) do
    @io = FakeAppIo.new
    @session = Session.new(@io, @io)
  end

  it 'updates the existing command log' do
    @io.log_content = "c,12\nz,10"
    @session = Session.new(@io, @io) 
    @session.log_command("z")
    expect(@io.log_content).to eq("c,12\nz,11")
  end

  it 'adds to existing command log' do
    @io.log_content = "c,12\nz,10\n"
    @session = Session.new(@io, @io) 
    @session.log_command("t")
    expect(@io.log_content).to eq("c,12\nz,10\nt,1")
  end

  it 'adds to an empty command log' do
    @io.log_content = ""
    @session = Session.new(@io, @io) 
    @session.log_command("t")
    expect(@io.log_content).to eq("t,1")
  end

end

describe 'Session#move_task_to_random_position_on_other_list' do
  before(:each) do
    @f_io = FakeAppIo.new
    @b_io = FakeAppIo.new
    @session = Session.new(@f_io, @b_io)
  end

  context 'when the foreground list is active' do
    xit 'moves the task at the cursor to a random position on the background list' do
      @f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      @b_io.actions_content = "Task A\nTask B\nTask C\n"
      @session.list.todo_cursor_set(1)

      expect(@b_io.actions_content.split("\n")).to receive(:insert).with(kind_of(Integer), "Task 2\n").and_call_original
      expect(@f_io.actions_content.split("\n")).to receive(:delete_at).with(1).and_call_original

      @session.move_task_to_random_position_on_other_list
    end

    it 'does not modify the lists if the foreground list is empty' do
      @f_io.actions_content = ""
      @b_io.actions_content = "Task A\nTask B\nTask C\n"

      expect(@b_io.actions_content.split("\n")).not_to receive(:insert)
      expect(@f_io.actions_content.split("\n")).not_to receive(:delete_at)

      @session.move_task_to_random_position_on_other_list
    end
  end

  context 'when the background list is active' do
    before { session.switch_lists }

    xit 'moves the task at the cursor to a random position on the foreground list' do
      @f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      @b_io.actions_content = "Task A\nTask B\nTask C\n"
      @session.list.todo_cursor_set(1)

      expect(@f_io.actions_content.split("\n")).to receive(:insert).with(kind_of(Integer), "Task B\n").and_call_original
      expect(@b_io.actions_content.split("\n")).to receive(:delete_at).with(1).and_call_original

      @session.move_task_to_random_position_on_other_list
    end

    xit 'does not modify the lists if the background list is empty' do
      @f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      @b_io.actions_content = ""

      expect(@f_io.actions_content.split("\n")).not_to receive(:insert)
      expect(@b_io.actions_content.split("\n")).not_to receive(:delete_at)

      @session.move_task_to_random_position_on_other_list
    end
  end
end

describe 'Session#surface' do
  before(:each) do
    @foreground_io = FakeAppIo.new
    @background_io = FakeAppIo.new
  end

  it 'does nothing if background list is empty' do
    expect(@foreground_io).to receive(:append_to_actions).never
    @session = Session.new(@foreground_io, @background_io)
    @session.surface(3)
    @session.save
  end

  it 'moves the specified number of random tasks from background to foreground' do
    @background_io.actions_content = "Task 1\nTask 2\nTask 3"
    @session = Session.new(@foreground_io, @background_io)
    
    @session.surface(2)
    @session.save

    expect(@foreground_io.actions_content.split("\n").size).to eq(2)
    expect(@background_io.actions_content.split("\n").size).to eq(1)
  end

  it 'moves all tasks from background to foreground if count exceeds background size' do
    @background_io.actions_content = "Task 1\nTask 2"
    @session = Session.new(@foreground_io, @background_io)
    @session.surface(5)
    @session.save

    expect(@foreground_io.actions_content.split("\n").size).to eq(2)
    expect(@background_io.actions_content).to eq("")
  end
end


