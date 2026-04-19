require 'spec_helper'
require 'session'
require 'commands/year_summaries'
require 'fakeappio'

describe YearSummaries do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { YearSummaries.new }

  before do
    f_io.today_content = Day.from_text("2024-06-15")
    f_io.archive_content = ""
  end

  describe '#matches?' do
    it 'matches "y"' do
      expect(command.matches?("y")).to be true
    end

    it 'matches "y" with whitespace' do
      expect(command.matches?(" y ")).to be true
    end

    it 'does not match other input' do
      expect(command.matches?("yes")).to be false
    end

    it 'does not match empty input' do
      expect(command.matches?("")).to be false
    end
  end

  describe '#process' do
    it 'runs the years report' do
      f_io.archive_content = "2023-01-01 L: task\n2024-03-15 R: task\n"

      command.process("y", session)

      expect(f_io.console_output_content).to include("Life")
      expect(f_io.console_output_content).to include("Total")
    end

    it 'works with empty archive' do
      command.process("y", session)

      expect(f_io.console_output_content).to include("Total")
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq("y")
      expect(desc.line).to eq("show year summaries")
    end
  end
end
