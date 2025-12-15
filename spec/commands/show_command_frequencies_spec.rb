require 'spec_helper'
require 'session'
require 'commands/show_command_frequencies'
require 'fakeappio'

describe ShowCommandFrequencies do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { ShowCommandFrequencies.new }

  describe '#matches?' do
    it 'matches "sf"' do
      expect(command.matches?('sf')).to be_truthy
    end

    it 'does not match "sf" with arguments' do
      expect(command.matches?('sf arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('s')).to be_falsey
      expect(command.matches?('freq')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls todo_show_command_frequencies on the list' do
      expect(mock_list).to receive(:todo_show_command_frequencies)

      command.run('sf', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('sf ')
      expect(desc.line).to eq('show command frequencies')
    end
  end
end
