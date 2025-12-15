require 'spec_helper'
require 'session'
require 'commands/today_target_for'
require 'fakeappio'

describe TodayTargetFor do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { TodayTargetFor.new }

  describe '#matches?' do
    it 'matches "tf" with a number argument' do
      expect(command.matches?('tf 30')).to be_truthy
      expect(command.matches?('tf 50')).to be_truthy
    end

    it 'does not match "tf" without arguments' do
      expect(command.matches?('tf')).to be_falsey
    end

    it 'does not match "tf" with more than one argument' do
      expect(command.matches?('tf 30 40')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('t')).to be_falsey
      expect(command.matches?('target')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls todo_target_for with the monthly goal' do
      expect(mock_list).to receive(:todo_target_for).with(30)

      command.run('tf 30', session)
    end

    it 'calls todo_target_for with different goal values' do
      expect(mock_list).to receive(:todo_target_for).with(50)

      command.run('tf 50', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('tf n')
      expect(desc.line).to eq('show how many more tasks are needed today to stay on track for n this month')
    end
  end
end
