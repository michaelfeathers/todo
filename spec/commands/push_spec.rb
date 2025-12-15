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
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls todo_push with the number of days' do
      expect(mock_list).to receive(:todo_push).with('5')

      command.run('p 5', session)
    end

    it 'calls todo_push with different day counts' do
      expect(mock_list).to receive(:todo_push).with('10')

      command.run('p 10', session)
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
