require 'spec_helper'
require 'commands/find'
require 'session'
require 'fakeappio'

describe Find do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { Find.new }

  describe '#matches?' do
    it 'returns true for "f" followed by text' do
      expect(command.matches?('f search_text')).to be true
    end

    it 'returns true for "f" followed by text and a number' do
      expect(command.matches?('f search_text 5')).to be true
    end

    it 'returns false for "f" alone' do
      expect(command.matches?('f')).to be false
    end

    it 'returns false for other commands' do
      expect(command.matches?('other_command')).to be false
    end
  end

  describe '#run' do
    before do
      f_io.tasks_content = "Task 1\nTask 2\nAnother task\nYet another task\n"
    end

    it 'finds tasks containing the specified text' do
      command.run('f task', session)
      expect(f_io.console_output_content).to include('Task 1')
      expect(f_io.console_output_content).to include('Task 2')
      expect(f_io.console_output_content).to include('Another task')
      expect(f_io.console_output_content).to include('Yet another task')
    end

    it 'limits results when a number is specified' do
      command.run('f task 2', session)
      expect(f_io.console_output_content.scan(/task/i).count).to eq(2)
    end

    it 'is case-insensitive' do
      command.run('f TASK', session)
      expect(f_io.console_output_content).to include('Task 1')
      expect(f_io.console_output_content).to include('Task 2')
    end

    it 'returns to prompt after displaying results' do
      expect(f_io).to receive(:get_from_console)
      command.run('f task', session)
    end

    it 'clears the console before displaying results' do
      expect(f_io).to receive(:clear_console)
      command.run('f task', session)
    end

    it 'displays the count of found tasks' do
      command.run('f task', session)
      expect(f_io.console_output_content).to include('4')
    end

    it 'handles no matches' do
      command.run('f nonexistent', session)
      expect(f_io.console_output_content).to include('0')
    end
  end
end
