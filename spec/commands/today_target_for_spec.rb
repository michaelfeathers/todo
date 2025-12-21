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
    it 'calculates tasks needed per day to meet monthly goal' do
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))
      f_io.archive_content = "2023-06-01 L: Task A\n2023-06-02 L: Task B\n2023-06-03 L: Task C\n"
      f_io.console_input_content = "\n"

      command.run('tf 30', session)

      expect(f_io.console_output_content).to include("Do 2 per day to meet monthly goal of 30")
      expect(f_io.console_output_content).to include("Daily average so far: 0.2")
    end

    it 'shows 0 tasks per day when goal is already exceeded' do
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))
      f_io.archive_content = "2023-06-01 L: Task A\n2023-06-02 L: Task B\n2023-06-03 L: Task C\n"
      f_io.console_input_content = "\n"

      command.run('tf 3', session)

      expect(f_io.console_output_content).to include("Do 0 per day to meet monthly goal of 3")
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
