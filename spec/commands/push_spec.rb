require 'spec_helper'
require 'session'
require 'commands/push'
require 'fakeappio'

describe Push do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { Push.new }

  describe '#matches?' do
    it 'matches "p" with a number argument' do
      expect(command.matches?('p 5')).to be_truthy
      expect(command.matches?('p 10')).to be_truthy
    end

    it 'does not match "p" without arguments' do
      expect(command.matches?('p')).to be_falsey
    end

    it 'does not match "p" with more than one argument' do
      expect(command.matches?('p 5 10')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('push')).to be_falsey
      expect(command.matches?('x')).to be_falsey
    end
  end

  describe '#process' do
    it 'pushes the task at cursor to updates with future date and removes it' do
      f_io.tasks_content = "L: task 1\nL: task 2\n"
      f_io.update_content = ""
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))

      command.run('p 5', session)

      expect(f_io.update_content.first).to eq("2023-06-20 L: task 1\n")
      expect(session.list.count).to eq(1)
      expect(session.list.task_at_cursor).to eq("L: task 2")
    end

    it 'pushes with different day counts' do
      f_io.tasks_content = "L: task A\n"
      f_io.update_content = ""
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))

      command.run('p 10', session)

      expect(f_io.update_content.first).to eq("2023-06-25 L: task A\n")
      expect(session.list.count).to eq(0)
    end

    it 'does not push when list is empty' do
      f_io.tasks_content = ""
      f_io.update_content = []
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))

      command.run('p 5', session)

      expect(f_io.update_content).to eq([])
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('p  n')
      expect(desc.line).to eq('push task at cursor forward n number of days')
    end
  end
end
