require 'spec_helper'
require 'session'
require 'commands/grab_toggle'
require 'fakeappio'

describe GrabToggle do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { GrabToggle.new }

  describe '#matches?' do
    it 'matches "g"' do
      expect(command.matches?('g')).to be_truthy
    end

    it 'does not match "g" with arguments' do
      expect(command.matches?('g arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('grab')).to be_falsey
      expect(command.matches?('x')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls grab_toggle on the list' do
      expect(mock_list).to receive(:grab_toggle)

      command.run('g', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('g')
      expect(desc.line).to eq('toggle grab mode')
    end
  end
end
