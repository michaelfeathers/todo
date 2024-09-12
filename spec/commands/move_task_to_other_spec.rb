require 'spec_helper'
require 'commands/move_task_to_other'
require 'session'
require 'fakeappio'


describe MoveTaskToOther do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'moves the task at the cursor from the foreground list to the background list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      session.list.cursor_set(1)

      MoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.tasks_content).to eq("Task 1\nTask 3\n")
      expect(b_io.tasks_content).to eq("Task 2\n")
    end

    it 'moves the task at the cursor from the background list to the foreground list' do
      b_io.tasks_content = "Task A\nTask B\nTask C\n"
      session.switch_lists
      session.list.cursor_set(1)

      MoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.tasks_content).to eq("Task B\n")
      expect(b_io.tasks_content).to eq("Task A\nTask C\n")
    end

    it 'does not modify the lists if the foreground list is empty' do
      f_io.tasks_content = ""
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      MoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.tasks_content).to eq("")
      expect(b_io.tasks_content).to eq("\nTask A\nTask B\nTask C\n")
    end

    it 'does not modify the lists if the background list is empty' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = ""
      session.switch_lists

      MoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.tasks_content).to eq("\nTask 1\nTask 2\nTask 3\n")
      expect(b_io.tasks_content).to eq("")
    end
  end

  describe '#matches?' do
    it 'matches a command with "-"' do
      expect(MoveTaskToOther.new.matches?('-')).to be_truthy
    end

    it 'does not match a command other than "-"' do
      expect(MoveTaskToOther.new.matches?('x')).to be_falsey
    end
  end
end
