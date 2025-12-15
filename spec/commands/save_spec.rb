require 'spec_helper'
require 'session'
require 'commands/save'
require 'fakeappio'

describe Save do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { Save.new }

  describe '#matches?' do
    it 'matches "s"' do
      expect(command.matches?('s')).to be_truthy
    end

    it 'does not match "s" with arguments' do
      expect(command.matches?('s arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('save')).to be_falsey
      expect(command.matches?('ss')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls todo_save on the list' do
      expect(mock_list).to receive(:todo_save)

      command.run('s', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('s')
      expect(desc.line).to eq('save task at cursor')
    end
  end
end
