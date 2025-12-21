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
    it 'displays trend data from archive' do
      f_io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n2020-01-12 L: Another thing\n"
      f_io.console_input_content = "\n"

      command.run('tr', session)

      expect(f_io.console_output_content).to eq("  1  2020-01-11\n  2  2020-01-12\n\n")
    end

    it 'displays empty trend when archive is empty' do
      f_io.archive_content = ""
      f_io.console_input_content = "\n"

      command.run('tr', session)

      expect(f_io.console_output_content).to eq("\n")
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
