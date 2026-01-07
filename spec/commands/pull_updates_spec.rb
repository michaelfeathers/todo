require 'spec_helper'
require 'session'
require 'commands/pull_updates'
require 'fakeappio'
require 'day'

describe PullUpdates do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { PullUpdates.new }

  describe '#matches?' do
    it 'matches "pu"' do
      expect(command.matches?('pu')).to be_truthy
    end

    it 'does not match "pu" with arguments' do
      expect(command.matches?('pu arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('p')).to be_falsey
      expect(command.matches?('pull')).to be_falsey
    end
  end

  describe '#process' do
    it 'pulls tomorrow\'s updates to foreground list' do
      today = Day.from_text('2023-12-01')
      tomorrow = '2023-12-02'
      f_io.today_content = today
      f_io.update_content = "#{tomorrow} Task for tomorrow\n2023-12-03 Task for later\n"
      f_io.tasks_content = ""

      command.run('pu', session)

      expect(session.foreground_tasks.task_at_cursor).to eq("Task for tomorrow")
      expect(f_io.update_content).to eq(["2023-12-03 Task for later\n"])
    end

    it 'pulls multiple tomorrow updates preserving order' do
      today = Day.from_text('2023-12-01')
      tomorrow = '2023-12-02'
      f_io.today_content = today
      f_io.update_content = "#{tomorrow} First task\n#{tomorrow} Second task\n2023-12-03 Future task\n"
      f_io.tasks_content = ""

      command.run('pu', session)

      # Tasks are added in reverse so they appear in original order
      expect(session.foreground_tasks.task_at_cursor).to eq("First task")
      session.foreground_tasks.down
      expect(session.foreground_tasks.task_at_cursor).to eq("Second task")
      expect(f_io.update_content).to eq(["2023-12-03 Future task\n"])
    end

    it 'does nothing when no tomorrow updates exist' do
      today = Day.from_text('2023-12-01')
      f_io.today_content = today
      f_io.update_content = "2023-12-03 Future task\n2023-12-04 Another future task\n"
      f_io.tasks_content = "Existing task\n"

      command.run('pu', session)

      expect(session.foreground_tasks.task_at_cursor).to eq("Existing task")
      expect(f_io.update_content).to eq(["2023-12-03 Future task\n", "2023-12-04 Another future task\n"])
    end

    it 'handles empty updates' do
      today = Day.from_text('2023-12-01')
      f_io.today_content = today
      f_io.update_content = ""
      f_io.tasks_content = ""

      command.run('pu', session)

      expect(session.foreground_tasks.task_at_cursor).to eq("")
      expect(f_io.update_content).to eq([])
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('pu')
      expect(desc.line).to eq("pull tomorrow's updates to foreground list")
    end
  end
end
