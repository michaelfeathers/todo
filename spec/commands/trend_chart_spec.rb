require 'spec_helper'
require 'session'
require 'commands/trend_chart'
require 'fakeappio'

describe TrendChart do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { TrendChart.new }

  describe '#matches?' do
    it 'matches "tc"' do
      expect(command.matches?('tc')).to be_truthy
    end

    it 'matches "tc" with a year argument' do
      expect(command.matches?('tc 2023')).to be_truthy
    end

    it 'does not match with more than one argument' do
      expect(command.matches?('tc 2023 2024')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('t')).to be_falsey
      expect(command.matches?('trend')).to be_falsey
    end
  end

  describe '#process' do
    let(:mock_gruff_chart) { instance_double(Gruff::Line) }

    before do
      allow(Gruff::Line).to receive(:new).and_return(mock_gruff_chart)
      allow(mock_gruff_chart).to receive(:theme=)
      allow(mock_gruff_chart).to receive(:data)
      allow(mock_gruff_chart).to receive(:write)
      allow(command).to receive(:`).and_return(nil)
    end

    it 'creates a chart without year filter' do
      f_io.archive_content = "2023-01-15 L: Task A\n2023-01-16 L: Task B\n"

      expect(Gruff::Line).to receive(:new).with(1600).and_return(mock_gruff_chart)
      expect(mock_gruff_chart).to receive(:data).with('', [1, 1])

      command.run('tc', session)
    end

    it 'creates a chart with year filter' do
      f_io.archive_content = "2022-12-31 L: Task 2022\n2023-01-01 L: Task 2023A\n2023-01-02 L: Task 2023B\n2024-01-01 L: Task 2024\n"

      expect(mock_gruff_chart).to receive(:data).with('', [1, 1])

      command.run('tc 2023', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('tc')
      expect(desc.line).to eq('show trend chart')
    end
  end
end
