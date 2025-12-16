require 'spec_helper'
require 'session'
require 'commands/month_summaries'
require 'fakeappio'
require 'testrenderer'
require 'monthsreport'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe MonthSummaries do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { MonthSummaries.new }

  describe '#matches?' do
    it 'matches "m"' do
      expect(command.matches?('m')).to be_truthy
    end

    it 'matches "m" with a year argument' do
      expect(command.matches?('m 2023')).to be_truthy
    end

    it 'does not match with more than one argument' do
      expect(command.matches?('m 2023 2024')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('mm')).to be_falsey
      expect(command.matches?('x')).to be_falsey
    end
  end

  describe '#process' do
    it 'calls todo_month_summaries on the list with no arguments' do
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))
      f_io.archive_content = "2023-01-01 L: Task 1\n2023-02-01 R: Task 2\n"

      mock_report = instance_double(MonthsReport)
      expect(MonthsReport).to receive(:new).with(f_io, 2023).and_return(mock_report)
      expect(mock_report).to receive(:run)

      command.run('m', session)
    end

    it 'calls todo_month_summaries on the list with a year argument' do
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))
      f_io.archive_content = "2022-01-01 L: Task 1\n2022-02-01 R: Task 2\n"

      mock_report = instance_double(MonthsReport)
      expect(MonthsReport).to receive(:new).with(f_io, 2022).and_return(mock_report)
      expect(mock_report).to receive(:run)

      command.run('m 2022', session)
    end

    it 'returns to the prompt after displaying summaries' do
      f_io.today_content = Day.new(DateTime.new(2023, 6, 15))
      f_io.archive_content = "2023-01-01 L: Task 1\n"

      expect(f_io).to receive(:get_from_console)

      command.run('m', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('m')
      expect(desc.line).to eq('show month summaries')
    end
  end

  describe 'today statistics' do
    it 'shows today statistics when viewing current year and tasks exist for today' do
      today = DateTime.new(2023, 6, 15)
      f_io.today_content = Day.new(today)
      f_io.archive_content = "2023-06-15 L: Task today\n2023-01-01 L: Task Jan\n"

      command.run('m 2023', session)

      expect(f_io.console_output_content).to include("Today")
    end

    it 'does not show today statistics when viewing a different year' do
      today = DateTime.new(2023, 6, 15)
      f_io.today_content = Day.new(today)
      f_io.archive_content = "2022-01-01 L: Task 2022\n2023-06-15 L: Task today\n"

      command.run('m 2022', session)

      expect(f_io.console_output_content).not_to include("Today")
    end
  end
end
