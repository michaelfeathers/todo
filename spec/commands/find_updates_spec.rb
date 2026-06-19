require 'spec_helper'
require 'commands/find_updates'
require 'session'
require 'fakeappio'

describe FindUpdates do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { FindUpdates.new }

  describe '#matches?' do
    it 'returns true for "fu" followed by text' do
      expect(command.matches?('fu search_text')).to be true
    end

    it 'returns true for "fu" followed by text and a number' do
      expect(command.matches?('fu search_text 5')).to be true
    end

    it 'returns false for "fu" alone' do
      expect(command.matches?('fu')).to be false
    end

    it 'returns false for "f" with text' do
      expect(command.matches?('f search_text')).to be false
    end
  end

  describe '#run' do
    before do
      f_io.tasks_content = "A matching task\n"
      f_io.update_content = "First update\nSecond matching update\nThird update\nFourth matching update\n"
    end

    it 'finds only updates containing the specified text' do
      command.run('fu matching', session)
      expect(f_io.console_output_content).to include('Second matching update')
      expect(f_io.console_output_content).to include('Fourth matching update')
    end

    it 'does not search the task list' do
      command.run('fu matching', session)
      expect(f_io.console_output_content).not_to include('A matching task')
    end

    it 'prefixes each found update with its right-justified position number' do
      command.run('fu matching', session)
      expect(f_io.console_output_content).to include('   2 Second matching update')
      expect(f_io.console_output_content).to include('   4 Fourth matching update')
    end

    it 'is case-insensitive' do
      command.run('fu MATCHING', session)
      expect(f_io.console_output_content).to include('Second matching update')
    end

    it 'limits the number of results when a count is given' do
      command.run('fu update 2', session)
      expect(f_io.console_output_content).to include('   1 First update')
      expect(f_io.console_output_content).to include('   2 Second matching update')
      expect(f_io.console_output_content).not_to include('   3 Third update')
    end

    it 'returns to prompt after displaying results' do
      expect(f_io).to receive(:get_from_console)
      command.run('fu matching', session)
    end

    it 'handles no matches' do
      command.run('fu nonexistent', session)
      expect(f_io.console_output_content).to include('0')
    end
  end

  describe '#description' do
    it 'returns the correct command name' do
      expect(command.description.name).to eq('fu text [n]')
    end
  end
end
