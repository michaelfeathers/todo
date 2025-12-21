require 'spec_helper'
require 'session'
require 'commands/show_updates'
require 'fakeappio'

describe ShowUpdates do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { ShowUpdates.new }

  describe '#matches?' do
    it 'matches "pp"' do
      expect(command.matches?('pp')).to be_truthy
    end

    it 'does not match "pp" with arguments' do
      expect(command.matches?('pp arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('p')).to be_falsey
      expect(command.matches?('updates')).to be_falsey
    end
  end

  describe '#process' do
    it 'displays updates with date toggle formatting' do
      f_io.update_content = "2023-12-01 Task 1\n2023-12-02 Task 2\n2023-12-02 Task 3\n2023-12-03 Task 4\n"
      f_io.console_input_content = "\n"

      command.run('pp', session)

      output = f_io.console_output_content

      # First date should be in reverse video
      expect(output).to include("\e[7m2023-12-01\e[0m Task 1")

      # Second date (different from first) should NOT be in reverse video
      expect(output).to include("2023-12-02 Task 2")

      # Third line (same date as second) should still NOT be in reverse video
      expect(output).to include("2023-12-02 Task 3")

      # Fourth date (different from second/third) should be in reverse video again
      expect(output).to include("\e[7m2023-12-03\e[0m Task 4")
    end

    it 'displays updates with same date without toggling' do
      f_io.update_content = "2023-12-01 Task 1\n2023-12-01 Task 2\n"
      f_io.console_input_content = "\n"

      command.run('pp', session)

      output = f_io.console_output_content

      # Both lines should have reverse video since they're the same date
      expect(output).to include("\e[7m2023-12-01\e[0m Task 1")
      expect(output).to include("\e[7m2023-12-01\e[0m Task 2")
    end

    it 'displays empty updates' do
      f_io.update_content = ""
      f_io.console_input_content = "\n"

      command.run('pp', session)

      expect(f_io.console_output_content).to eq("")
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('pp')
      expect(desc.line).to eq('show updates')
    end
  end
end
