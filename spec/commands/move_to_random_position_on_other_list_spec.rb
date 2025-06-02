require 'spec_helper'
require 'session'
require 'commands/move_to_random_position_on_other_list'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n"

describe MoveToRandomPositionOnOtherList do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }

  describe '#run' do
    it 'moves the task at the cursor from the foreground list to a random position on the background list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"
      session.list.cursor_set(1)

      expect_any_instance_of(Session).to receive(:move_task_to_random_position_on_other_list)

      MoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'moves the task at the cursor from the background list to a random position on the foreground list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"
      session.switch_lists
      session.list.cursor_set(1)

      expect_any_instance_of(Session).to receive(:move_task_to_random_position_on_other_list)

      MoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'does not modify the lists if the foreground list is empty' do
      f_io.tasks_content = ""
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      expect_any_instance_of(Session).not_to receive(:move_task_to_random_position_on_other_list)

      MoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'does not modify the lists if the background list is empty' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = ""
      session.switch_lists

      expect_any_instance_of(Session).not_to receive(:move_task_to_random_position_on_other_list)

      MoveToRandomPositionOnOtherList.new.run('_', session)
    end
  end

  describe '#matches?' do
    it 'matches a command with "_"' do
      expect(MoveToRandomPositionOnOtherList.new.matches?('_')).to be_truthy
    end

    it 'does not match a command other than "_"' do
      expect(MoveToRandomPositionOnOtherList.new.matches?('x')).to be_falsey
    end
  end
end