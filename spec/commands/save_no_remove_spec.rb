require 'spec_helper'
require 'session'
require 'commands/save_no_remove'
require 'fakeappio'

describe SaveNoRemove do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { SaveNoRemove.new }

  describe '#matches?' do
    it 'matches "ss"' do
      expect(command.matches?('ss')).to be_truthy
    end

    it 'does not match "ss" with arguments' do
      expect(command.matches?('ss arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('s')).to be_falsey
      expect(command.matches?('save')).to be_falsey
    end
  end

  describe '#process' do
    it 'saves the task at cursor to archive without removing it' do
      f_io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"
      f_io.today_content = Day.new(DateTime.new(2023, 6, 1))
      session.list.cursor_set(1)

      command.run('ss', session)

      expect(f_io.archive_content).to eq("2023-06-01 L: task 2\n")
      expect(session.list.count).to eq(3)
      expect(session.list.task_at_cursor).to eq("L: task 2")
    end

    it 'does not save when list is empty' do
      f_io.tasks_content = ""

      command.run('ss', session)

      expect(f_io.archive_content).to eq("")
    end

    it 'does not save when task at cursor is empty' do
      f_io.tasks_content = "L: task 1\n\nL: task 3\n"
      f_io.today_content = Day.new(DateTime.new(2023, 6, 1))
      session.list.cursor_set(1)

      command.run('ss', session)

      expect(f_io.archive_content).to eq("")
      expect(session.list.count).to eq(3)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('ss')
      expect(desc.line).to eq('save task at cursor without removing')
    end
  end
end
