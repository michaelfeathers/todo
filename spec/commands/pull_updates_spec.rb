require 'spec_helper'
require 'session'
require 'commands/pull_updates'
require 'fakeappio'

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
    it 'pulls the next day\'s updates to foreground list' do
      f_io.update_content = "2023-12-02 Task for next day\n2023-12-03 Task for later\n"
      f_io.tasks_content = ""

      command.run('pu', session)

      expect(session.foreground_tasks.task_at_cursor).to eq("Task for next day")
      session.foreground_tasks.down
      expect(session.foreground_tasks.task_at_cursor).to eq("")
      expect(f_io.update_content).to eq(["2023-12-03 Task for later\n"])
    end

    it 'pulls multiple updates for the earliest date preserving order' do
      f_io.update_content = "2023-12-02 First task\n2023-12-02 Second task\n2023-12-03 Future task\n"
      f_io.tasks_content = ""

      command.run('pu', session)

      # Tasks are added in reverse so they appear in original order
      expect(session.foreground_tasks.task_at_cursor).to eq("First task")
      session.foreground_tasks.down
      expect(session.foreground_tasks.task_at_cursor).to eq("Second task")
      session.foreground_tasks.down
      expect(session.foreground_tasks.task_at_cursor).to eq("")
      expect(f_io.update_content).to eq(["2023-12-03 Future task\n"])
    end

    it 'pulls earliest date even when updates are not sorted' do
      f_io.update_content = "2023-12-05 Later task\n2023-12-02 Earlier task\n2023-12-03 Middle task\n"
      f_io.tasks_content = ""

      command.run('pu', session)

      expect(session.foreground_tasks.task_at_cursor).to eq("Earlier task")
      session.foreground_tasks.down
      expect(session.foreground_tasks.task_at_cursor).to eq("")
      expect(f_io.update_content).to eq(["2023-12-05 Later task\n", "2023-12-03 Middle task\n"])
    end

    it 'handles empty updates' do
      f_io.update_content = ""
      f_io.tasks_content = ""

      command.run('pu', session)

      expect(session.foreground_tasks.task_at_cursor).to eq("")
      expect(f_io.update_content).to eq("")
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('pu')
      expect(desc.line).to eq("pull next day's updates to foreground list")
    end
  end
end
