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

  describe '#get_line' do
    it 'returns the input from console with newline removed' do
      @io.console_input_content = "test input\n"
      result = @session.get_line
      expect(result).to eq("test input")
    end

    it 'returns empty string when input is nil' do
      @io.console_input_content = nil
      result = @session.get_line
      expect(result).to eq("")
    end

    it 'returns empty string when input is empty' do
      @io.console_input_content = ""
      result = @session.get_line
      expect(result).to eq("")
    end
  end

end

describe 'Session#move_task_to_random_position_on_other_list' do
  before(:each) do
    @foreground_io = FakeAppIo.new
    @background_io = FakeAppIo.new
  end

  context 'moving from foreground to background' do
    it 'moves the task at cursor to a random position on the background list' do
      @foreground_io.tasks_content = "Task 1\nTask 2\nTask 3"
      @background_io.tasks_content = "Task A\nTask B\nTask C"
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.list.cursor_set(1)

      # Mock rand to return position 1
      allow(@session).to receive(:rand).with(3).and_return(1)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n")
      background_tasks = @background_io.tasks_content.split("\n")

      expect(foreground_tasks).to eq(["Task 1", "Task 3"])
      expect(background_tasks).to eq(["Task A", "Task 2", "Task B", "Task C"])
    end

    it 'moves the task to the beginning when rand returns 0' do
      @foreground_io.tasks_content = "Task 1\nTask 2\nTask 3"
      @background_io.tasks_content = "Task A\nTask B"
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.list.cursor_set(0)

      # Mock rand to return position 0
      allow(@session).to receive(:rand).with(2).and_return(0)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n")
      background_tasks = @background_io.tasks_content.split("\n")

      expect(foreground_tasks).to eq(["Task 2", "Task 3"])
      expect(background_tasks).to eq(["Task 1", "Task A", "Task B"])
    end

    it 'moves the task to the end when rand returns the last position' do
      @foreground_io.tasks_content = "Task 1\nTask 2\nTask 3"
      @background_io.tasks_content = "Task A\nTask B"
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.list.cursor_set(2)

      # Mock rand to return the last position (count - 1)
      allow(@session).to receive(:rand).with(2).and_return(1)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n")
      background_tasks = @background_io.tasks_content.split("\n")

      expect(foreground_tasks).to eq(["Task 1", "Task 2"])
      expect(background_tasks).to eq(["Task A", "Task 3", "Task B"])
    end
  end

  context 'moving from background to foreground' do
    it 'moves the task at cursor to a random position on the foreground list' do
      @foreground_io.tasks_content = "Task 1\nTask 2\nTask 3"
      @background_io.tasks_content = "Task A\nTask B\nTask C"
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.switch_lists
      @session.list.cursor_set(1)

      # Mock rand to return position 2
      allow(@session).to receive(:rand).with(3).and_return(2)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n")
      background_tasks = @background_io.tasks_content.split("\n")

      expect(background_tasks).to eq(["Task A", "Task C"])
      expect(foreground_tasks).to eq(["Task 1", "Task 2", "Task B", "Task 3"])
    end

    it 'moves the task to foreground when background has multiple tasks' do
      @foreground_io.tasks_content = "Task 1"
      @background_io.tasks_content = "Task A\nTask B\nTask C"
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.switch_lists
      @session.list.cursor_set(0)

      # Mock rand to return position 0
      allow(@session).to receive(:rand).with(1).and_return(0)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n")
      background_tasks = @background_io.tasks_content.split("\n")

      expect(background_tasks).to eq(["Task B", "Task C"])
      expect(foreground_tasks).to eq(["Task A", "Task 1"])
    end
  end

  context 'edge cases' do
    it 'moves task to an empty background list' do
      @foreground_io.tasks_content = "Task 1\nTask 2"
      @background_io.tasks_content = ""
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.list.cursor_set(0)

      # Mock rand to return 0 (empty list has count 0)
      allow(@session).to receive(:rand).with(0).and_return(0)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n").reject(&:empty?)
      background_tasks = @background_io.tasks_content.split("\n").reject(&:empty?)

      expect(foreground_tasks).to eq(["Task 2"])
      expect(background_tasks).to eq(["Task 1"])
    end

    it 'moves task to an empty foreground list' do
      @foreground_io.tasks_content = ""
      @background_io.tasks_content = "Task A\nTask B"
      @session = Session.from_ios(@foreground_io, @background_io)
      @session.switch_lists
      @session.list.cursor_set(1)

      # Mock rand to return 0 (empty list has count 0)
      allow(@session).to receive(:rand).with(0).and_return(0)

      @session.move_task_to_random_position_on_other_list
      @session.save

      foreground_tasks = @foreground_io.tasks_content.split("\n").reject(&:empty?)
      background_tasks = @background_io.tasks_content.split("\n").reject(&:empty?)

      expect(background_tasks).to eq(["Task A"])
      expect(foreground_tasks).to eq(["Task B"])
    end
  end
end


