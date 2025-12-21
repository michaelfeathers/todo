require 'spec_helper'
require 'session'
require 'commands/show_command_frequencies'
require 'fakeappio'

describe ShowCommandFrequencies do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { ShowCommandFrequencies.new }

  describe '#matches?' do
    it 'matches "sf"' do
      expect(command.matches?('sf')).to be_truthy
    end

    it 'does not match "sf" with arguments' do
      expect(command.matches?('sf arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('s')).to be_falsey
      expect(command.matches?('freq')).to be_falsey
    end
  end

  describe '#process' do
    it 'displays command frequencies from log' do
      f_io.log_content = "save,100 add,50 quit,25 help,25"
      f_io.console_input_content = "\n"

      command.run('sf', session)

      expected_output = "\n50.00  100    save\n25.00  50     add\n12.50  25     quit\n12.50  25     help\n\n"
      expect(f_io.console_output_content).to eq(expected_output)
    end

    it 'displays empty output when log is empty' do
      f_io.log_content = ""
      f_io.console_input_content = "\n"

      command.run('sf', session)

      expect(f_io.console_output_content).to eq("\n\n\n")
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('sf ')
      expect(desc.line).to eq('show command frequencies')
    end
  end
end
