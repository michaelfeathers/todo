require 'spec_helper'
require 'session'
require 'commands/detail_toggle'
require 'fakeappio'

describe DetailToggle do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { DetailToggle.new }

  describe '#matches?' do
    it 'matches "~"' do
      expect(command.matches?('~')).to be_truthy
    end

    it 'does not match "~" with arguments' do
      expect(command.matches?('~ arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('d')).to be_falsey
      expect(command.matches?('x')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls detail_toggle on the list' do
      expect(mock_list).to receive(:detail_toggle)

      command.run('~', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('~')
      expect(desc.line).to eq('toggle display of tags')
    end
  end
end
