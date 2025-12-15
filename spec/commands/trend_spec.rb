require 'spec_helper'
require 'session'
require 'commands/trend'
require 'fakeappio'

describe Trend do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { Trend.new }

  describe '#matches?' do
    it 'matches "tr"' do
      expect(command.matches?('tr')).to be_truthy
    end

    it 'does not match "tr" with arguments' do
      expect(command.matches?('tr arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('t')).to be_falsey
      expect(command.matches?('trend')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_list) { instance_double(TaskList) }

    before do
      allow(session).to receive(:on_list).and_yield(mock_list)
    end

    it 'calls todo_trend on the list' do
      expect(mock_list).to receive(:todo_trend)

      command.run('tr', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('tr')
      expect(desc.line).to eq('show trend')
    end
  end
end
