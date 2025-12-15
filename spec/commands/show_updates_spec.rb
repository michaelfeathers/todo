require 'spec_helper'
require 'session'
require 'commands/show_updates'
require 'fakeappio'

describe ShowUpdates do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { ShowUpdates.new }

  describe '#matches?' do
    it 'matches "pp"' do
      expect(command.matches?('pp')).to be_truthy
    end

    it 'does not match "pp" with arguments' do
      expect(command.matches?('pp arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('p')).to be_falsey
      expect(command.matches?('updates')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls todo_show_updates on the list' do
      expect(mock_list).to receive(:todo_show_updates)

      command.run('pp', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('pp')
      expect(desc.line).to eq('show updates')
    end
  end
end
