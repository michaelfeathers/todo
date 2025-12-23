require 'spec_helper'
require 'session'
require 'commands/help'
require 'fakeappio'


class TestingHelp < Help
  attr_accessor :descs

  def command_descs
    @descs
  end
end

describe Help do
  let(:io) { FakeAppIo.new }
  let(:session) { Session.from_ios(io, io) }
  let(:help_command) { TestingHelp.new }

  it 'displays help information for each command' do
    commands = [
      ["cmd1", "description 1"],
      ["cmd2", "description 2"],
      ["cmd3", "description 3"]
    ]

    help_command = TestingHelp.new
    help_command.descs = commands
    help_command.run("h", session)

    expect(io.console_output_content).to include("cmd1     - description 1")
    expect(io.console_output_content).to include("cmd2     - description 2")
    expect(io.console_output_content).to include("cmd3     - description 3")
  end

  it 'aligns command names and descriptions properly' do
    commands = [
      ["short", "a short command"],
      ["a_very_long_command", "a long command"],
      ["medium_length", "a medium length command"]
    ]

    sorted_commands = commands.sort_by { |cmd| cmd[0] }

    max_length = 19
    format = "%-#{max_length + 5}s- %s"

    expected_output = "\n" + sorted_commands.map { |cmd| format % cmd }.join("\n") + "\n\n"

    help_command = TestingHelp.new
    help_command.descs = sorted_commands
    help_command.run("h", session)

    expect(io.console_output_content).to eq(expected_output)
  end

  it 'returns to the prompt after displaying help' do
    commands = [
      ["cmd1", "description 1"],
      ["cmd2", "description 2"]
    ]

    expect(io).to receive(:get_from_console)

    help_command = TestingHelp.new
    help_command.descs = commands
    help_command.run("h", session)
  end

  describe '#command_descs' do
    it 'maps registered commands to description arrays' do
      # Create mock commands with descriptions
      mock_cmd1 = double('Command1')
      mock_cmd2 = double('Command2')

      allow(mock_cmd1).to receive(:description).and_return(CommandDesc.new('cmd1', 'description 1'))
      allow(mock_cmd2).to receive(:description).and_return(CommandDesc.new('cmd2', 'description 2'))

      # Stub the ToDo constant and its registered_commands method
      todo_class = class_double('ToDo').as_stubbed_const
      allow(todo_class).to receive(:registered_commands).and_return([mock_cmd1, mock_cmd2])

      real_help = Help.new
      descs = real_help.command_descs

      expect(descs).to eq([['cmd1', 'description 1'], ['cmd2', 'description 2']])
    end
  end

  it 'lists all the commands' do
    NON_CMD_LINE_COUNT = 2
    CURRENT_CMD_COUNT = 41

    # Load all command files manually
    Dir[File.expand_path('../../../lib/commands/*.rb', __FILE__)].each { |f| require f }

    commands = ObjectSpace.each_object(Class)
                          .select { |klass| klass < Command }
                          .reject { |klass| klass == TestingHelp || klass.name == 'TestCommand' }
                          .select { |klass| klass.name && klass.instance_methods(false).include?(:description) }
                          .sort_by { |klass| klass.name }
                          .map {|k| k.new.description }


    help = TestingHelp.new
    help.descs = commands
    help.run("h", session)

    # iterate for coverage
    help.command_descs.map {|x| x.name + " " + x.line }

    expect(io.console_output_content.lines.count - NON_CMD_LINE_COUNT).to eq(CURRENT_CMD_COUNT)
  end
end
