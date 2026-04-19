require 'spec_helper'
require 'yearsreport'
require 'fakeappio'

TEST_YR_COLUMNS = [["Win",   ->(tasks) { tasks.W.count } ],
                   ["Life",  ->(tasks) { tasks.L.count } ],
                   ["Total", ->(tasks) { tasks.count } ]]

describe YearsReport do
  let(:io) { FakeAppIo.new }

  describe '#run' do
    it 'displays report and waits for input' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-06-15")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      report.run

      expect(io.console_output_content).to include("Win")
      expect(io.console_output_content).to include("Life")
      expect(io.console_output_content).to include("Total")
    end
  end

  describe '#header_row' do
    it 'formats column headers' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      row = report.header_row

      expect(row).to include("Win")
      expect(row).to include("Life")
      expect(row).to include("Total")
    end
  end

  describe '#years' do
    it 'returns empty array when archive is empty' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      expect(report.years).to eq([])
    end

    it 'returns range from earliest archive year to current year' do
      io.archive_content = "2022-03-01 L: task\n2023-05-10 W: task\n"
      io.today_content = Day.from_text("2024-06-15")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      expect(report.years).to eq([2022, 2023, 2024])
    end

    it 'returns single year when archive has only current year' do
      io.archive_content = "2024-01-01 L: task\n"
      io.today_content = Day.from_text("2024-06-15")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      expect(report.years).to eq([2024])
    end
  end

  describe '#all_tasks' do
    it 'returns a TaskSelection with all archived tasks' do
      io.archive_content = "2023-01-01 L: task\n2023-06-01 W: task\n"
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      expect(report.all_tasks.count).to eq(2)
    end

    it 'returns empty TaskSelection for empty archive' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      expect(report.all_tasks.count).to eq(0)
    end
  end

  describe '#read_task_descs' do
    it 'parses archive lines into TaskDesc objects' do
      io.archive_content = "2023-01-15 L: task one\n2023-06-20 W: task two\n"
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      descs = report.read_task_descs

      expect(descs.size).to eq(2)
      expect(descs[0].task_type).to eq("L")
      expect(descs[1].task_type).to eq("W")
    end

    it 'caches the result' do
      io.archive_content = "2023-01-15 L: task\n"
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      first_call = report.read_task_descs
      second_call = report.read_task_descs

      expect(first_call).to equal(second_call)
    end
  end

  describe '#body_row' do
    it 'formats a row with label and computed values' do
      io.archive_content = "2023-01-01 L: task\n2023-02-01 W: task\n"
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      row = report.body_row("2023", report.all_tasks)

      expect(row).to include("2023")
      expect(row).to include("1")  # Win count
      expect(row).to include("2")  # Total count
    end
  end

  describe '#print_header' do
    it 'outputs header with column names' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      report.print_header

      expect(io.console_output_content).to include("Win")
      expect(io.console_output_content).to include("Total")
    end
  end

  describe '#print_body' do
    it 'outputs per-year rows and total row' do
      io.archive_content = "2022-03-01 L: task\n2023-05-10 W: task\n"
      io.today_content = Day.from_text("2023-12-31")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      report.print_body

      expect(io.console_output_content).to include("2022")
      expect(io.console_output_content).to include("2023")
    end

    it 'outputs total statistics row' do
      io.archive_content = "2023-01-01 L: a\n2023-06-01 L: b\n"
      io.today_content = Day.from_text("2023-12-31")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      report.print_body

      # Total row should show 2 for total and life columns
      expect(io.console_output_content).to include("2")
    end
  end

  describe '#print_footer' do
    it 'outputs a newline' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      io.console_output_content = ""
      report.print_footer

      expect(io.console_output_content).to eq($/)
    end
  end

  describe '#print_years_statistics' do
    it 'outputs nothing for empty archive' do
      io.archive_content = ""
      io.today_content = Day.from_text("2024-01-01")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      io.console_output_content = ""
      report.print_years_statistics

      # Just a trailing newline, no year rows
      expect(io.console_output_content).to eq($/)
    end

    it 'outputs a row for each year' do
      io.archive_content = "2021-01-01 L: a\n2022-06-01 W: b\n2023-12-01 L: c\n"
      io.today_content = Day.from_text("2023-12-31")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      report.print_years_statistics

      expect(io.console_output_content).to include("2021")
      expect(io.console_output_content).to include("2022")
      expect(io.console_output_content).to include("2023")
    end
  end

  describe '#print_total_statistics' do
    it 'outputs a total row' do
      io.archive_content = "2023-01-01 L: a\n2023-06-01 W: b\n"
      io.today_content = Day.from_text("2023-12-31")

      report = YearsReport.new(io, TEST_YR_COLUMNS)
      io.console_output_content = ""
      report.print_total_statistics

      # Should contain total count of 2
      expect(io.console_output_content).to include("2")
    end
  end

  describe 'with default SUMMARY_COLUMNS' do
    it 'runs without error' do
      io.archive_content = "2023-01-01 L: task\n2023-06-01 R: task\n"
      io.today_content = Day.from_text("2023-12-31")

      report = YearsReport.new(io)
      report.run

      expect(io.console_output_content).to include("Life")
      expect(io.console_output_content).to include("Work")
      expect(io.console_output_content).to include("Total")
    end
  end
end
