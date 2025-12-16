require 'spec_helper'
require 'command'

# Test command class that won't be picked up by ObjectSpace in other tests
class TestCommand < Command
  def matches?(line)
    line == 'test'
  end

  def process(line, session)
    # Test implementation
  end

  def description
    CommandDesc.new('test cmd', 'test command description')
  end
end

describe CommandResult do
  let(:result) { CommandResult.new }
  let(:mock_command) { instance_double(Command) }

  describe '#initialize' do
    it 'initializes with an empty matches array' do
      expect(result.matches).to eq([])
    end
  end

  describe '#record_match' do
    it 'adds a command to the matches array' do
      result.record_match(mock_command)
      expect(result.matches).to eq([mock_command])
    end

    it 'records multiple commands' do
      mock_command2 = instance_double(Command)
      result.record_match(mock_command)
      result.record_match(mock_command2)
      expect(result.matches).to eq([mock_command, mock_command2])
    end
  end

  describe '#match_count' do
    it 'returns 0 when no matches are recorded' do
      expect(result.match_count).to eq(0)
    end

    it 'returns the number of recorded matches' do
      result.record_match(mock_command)
      result.record_match(instance_double(Command))
      result.record_match(instance_double(Command))
      expect(result.match_count).to eq(3)
    end
  end
end

describe Command do
  let(:command) { TestCommand.new }
  let(:session) { instance_double('Session') }
  let(:result) { CommandResult.new }

  describe '#run' do
    context 'when the command matches' do
      it 'records the match in the result' do
        command.run('test', session, result)
        expect(result.match_count).to eq(1)
        expect(result.matches).to include(command)
      end

      it 'processes the command' do
        expect(command).to receive(:process).with('test', session)
        command.run('test', session, result)
      end
    end

    context 'when the command does not match' do
      it 'does not record a match' do
        command.run('nomatch', session, result)
        expect(result.match_count).to eq(0)
      end

      it 'does not process the command' do
        expect(command).not_to receive(:process)
        command.run('nomatch', session, result)
      end
    end
  end

  describe '#name' do
    it 'returns the first word of the description name' do
      expect(command.name).to eq('test')
    end

    it 'handles single-word command names' do
      test_cmd = TestCommand.new
      allow(test_cmd).to receive(:description).and_return(CommandDesc.new('save', 'save description'))
      expect(test_cmd.name).to eq('save')
    end

    it 'handles multi-word command names with arguments' do
      test_cmd = TestCommand.new
      allow(test_cmd).to receive(:description).and_return(CommandDesc.new('tc [year]', 'trend chart'))
      expect(test_cmd.name).to eq('tc')
    end
  end
end
