require 'spec_helper'
require 'session'
require 'commands/add'
require 'fakeappio'


describe Add do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'adds a new task to the beginning of the list' do
      Add.new.run('a New task', session)
      expect(session.list.task_at_cursor).to eq('New task')
    end

    it 'sets the cursor to the newly added task' do
      Add.new.run('a New task', session)
      Add.new.run('a Another task', session)
      expect(session.list.task_at_cursor).to eq('Another task')
    end

    it 'trims leading and trailing whitespace from the task text' do
      Add.new.run('a   Task with whitespace   ', session)
      expect(session.list.task_at_cursor).to eq('Task with whitespace')
    end

    it 'does not add an empty task' do
      Add.new.run('a', session)
      expect(session.list.task_at_cursor).to eq('')
    end

    it 'adds multiple tasks in the correct order' do
      Add.new.run('a Task 1', session)
      Add.new.run('a Task 2', session)
      Add.new.run('a Task 3', session)

      expect(session.list.task_at_cursor).to eq('Task 3')
      session.list.down
      expect(session.list.task_at_cursor).to eq('Task 2')
      session.list.down
      expect(session.list.task_at_cursor).to eq('Task 1')
    end
  end

  describe '#matches?' do
    it 'matches a command starting with "a"' do
      expect(Add.new.matches?('a New task')).to be_truthy
    end

    it 'does not match a command not starting with "a"' do
      expect(Add.new.matches?('x New task')).to be_falsey
    end
  end
end
