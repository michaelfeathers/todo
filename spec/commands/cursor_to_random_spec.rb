require 'spec_helper'
require 'session'
require 'commands/cursor_to_random'
require 'fakeappio'


describe CursorToRandom do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { CursorToRandom.new }

  describe '#matches?' do
    it 'matches "cr"' do
      expect(command.matches?('cr')).to be_truthy
    end

    it 'does not match "cr" with arguments' do
      expect(command.matches?('cr 5')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('c')).to be_falsey
      expect(command.matches?('cc')).to be_falsey
      expect(command.matches?('random')).to be_falsey
    end
  end

  describe '#process' do
    it 'moves the cursor to a random position in the list' do
      tasks = [
        "L: task 0\n",
        "L: task 1\n",
        "L: task 2\n",
        "L: task 3\n",
        "L: task 4\n"
      ]
      f_io.tasks_content = tasks.join
      session.list.cursor_set(0)

      command.run('cr', session)

      # Cursor should be somewhere between 0 and 4
      cursor_position = session.list.window.find { |_, marker, _| marker == '-' }&.first
      expect(cursor_position).to be_between(0, 4)
    end

    it 'handles empty list gracefully' do
      f_io.tasks_content = ""

      expect { command.run('cr', session) }.not_to raise_error
      expect(session.list.empty?).to be true
    end

    it 'works with single task list' do
      f_io.tasks_content = "L: only task\n"

      command.run('cr', session)

      # With only one task, cursor must be at position 0
      expect(session.list.task_at_cursor).to eq("L: only task")
      cursor_position = session.list.window.first&.first
      expect(cursor_position).to eq(0)
    end

    it 'selects from full range of tasks' do
      # Create a larger list and run multiple times to verify randomness
      tasks = 20.times.map { |i| "L: task #{i}\n" }
      f_io.tasks_content = tasks.join

      positions = Set.new
      10.times do
        command.run('cr', session)
        cursor_position = session.list.window.find { |_, marker, _| marker == '-' }&.first
        positions << cursor_position
      end

      # With 10 random selections from 20 tasks, we should see some variety
      # (not a guarantee, but extremely likely)
      expect(positions.size).to be > 1
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('cr')
      expect(desc.line).to eq('move cursor to a random task')
    end
  end
end
