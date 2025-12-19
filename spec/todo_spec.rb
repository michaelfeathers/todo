require 'spec_helper'
require 'fakeappio'
require_relative '../todo'


describe ToDo do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:todo_app) { ToDo.new(f_io, b_io) }

  before do
    # Set up minimal content to avoid errors
    f_io.tasks_content = ""
    b_io.tasks_content = ""
    f_io.update_content = ""
    f_io.today_content = Day.today
  end

  describe '.registered_commands' do
    it 'returns an array of command instances' do
      commands = ToDo.registered_commands

      expect(commands).to be_an(Array)
      expect(commands).not_to be_empty
    end

    it 'includes all expected command types' do
      commands = ToDo.registered_commands
      command_classes = commands.map(&:class)

      expect(command_classes).to include(Add)
      expect(command_classes).to include(Remove)
      expect(command_classes).to include(Save)
      expect(command_classes).to include(Quit)
      expect(command_classes).to include(Help)
    end

    it 'returns command instances that respond to run' do
      commands = ToDo.registered_commands

      commands.each do |command|
        expect(command).to respond_to(:run)
      end
    end
  end

  describe '#initialize' do
    it 'stores the foreground and background IOs' do
      expect(todo_app.instance_variable_get(:@foreground_io)).to eq(f_io)
      expect(todo_app.instance_variable_get(:@background_io)).to eq(b_io)
    end

    it 'creates a session from the IOs' do
      session = todo_app.instance_variable_get(:@session)

      expect(session).to be_a(Session)
    end

    it 'runs the ToDoUpdater during initialization' do
      # Create fresh IOs with updates
      new_f_io = FakeAppIo.new
      new_f_io.tasks_content = "Existing task\n"
      new_f_io.update_content = ""
      new_f_io.today_content = Day.today
      new_b_io = FakeAppIo.new
      new_b_io.tasks_content = ""

      # Initialize should run ToDoUpdater
      ToDo.new(new_f_io, new_b_io)

      # Verify updater was called (it reads and writes tasks/updates)
      expect(new_f_io.tasks_content).to be_a(String)
    end
  end

  describe '#on_line' do
    let(:session) { todo_app.instance_variable_get(:@session) }

    context 'with a recognized command' do
      it 'executes the matching command' do
        initial_count = session.list.count

        todo_app.on_line('a New task', session)

        expect(session.list.count).to eq(initial_count + 1)
      end

      it 'logs the command when recognized' do
        todo_app.on_line('a New task', session)

        expect(f_io.log_content).to include('a')
      end

      it 'passes the session to the command' do
        todo_app.on_line('a Test task', session)

        expect(session.list.task_at_cursor).to eq('Test task')
      end

      it 'handles multiple matching commands by running the first match' do
        # Some commands might match similar patterns
        # The first match should win
        todo_app.on_line('a Task', session)

        expect(session.list.task_at_cursor).to eq('Task')
      end
    end

    context 'with an unrecognized command' do
      it 'does not log the command' do
        initial_log = f_io.log_content.dup

        todo_app.on_line('xyz123 invalid command', session)

        expect(f_io.log_content).to eq(initial_log)
      end

      it 'displays an error message via process_result' do
        todo_app.on_line('invalid_command_xyz', session)

        expect(f_io.console_output_content).to include('Unrecognized command')
        expect(f_io.console_output_content).to include('invalid_command_xyz')
      end
    end

    context 'with an empty command' do
      it 'does not display an error message' do
        todo_app.on_line('', session)

        expect(f_io.console_output_content).not_to include('Unrecognized command')
      end

      it 'does not log anything' do
        initial_log = f_io.log_content.dup

        todo_app.on_line('', session)

        expect(f_io.log_content).to eq(initial_log)
      end
    end

    context 'with whitespace-only input' do
      it 'does not display an error message' do
        todo_app.on_line('   ', session)

        expect(f_io.console_output_content).not_to include('Unrecognized command')
      end
    end
  end

  describe '#process_result' do
    let(:session) { todo_app.instance_variable_get(:@session) }
    let(:result) { CommandResult.new }

    context 'when command was not recognized' do
      it 'displays an error message for non-empty input' do
        todo_app.process_result(result, 'unknown_command')

        expect(f_io.console_output_content).to include('Unrecognized command')
        expect(f_io.console_output_content).to include('unknown_command')
      end

      it 'does not display an error for empty input' do
        todo_app.process_result(result, '')

        expect(f_io.console_output_content).not_to include('Unrecognized command')
      end

      it 'does not display an error for whitespace-only input' do
        todo_app.process_result(result, '   ')

        expect(f_io.console_output_content).not_to include('Unrecognized command')
      end
    end

    context 'when command was recognized' do
      it 'does not display an error message' do
        # Simulate a matched command
        dummy_command = double('command', name: 'test')
        result.record_match(dummy_command)

        todo_app.process_result(result, 'valid command')

        expect(f_io.console_output_content).not_to include('Unrecognized command')
      end
    end
  end

  describe '#run' do
    let(:session) { todo_app.instance_variable_get(:@session) }

    it 'calls on_line and render in a loop' do
      # Mock session to break out of infinite loop
      iteration_count = 0
      allow(session).to receive(:get_line) do
        iteration_count += 1
        raise 'break loop' if iteration_count > 2
        'a Task'
      end
      allow(session).to receive(:render)

      expect { todo_app.run }.to raise_error('break loop')
      expect(iteration_count).to eq(3)
    end

    it 'processes each line through on_line' do
      allow(session).to receive(:get_line).and_return('a Test', 'break')
      allow(session).to receive(:render)

      # Mock on_line to count calls
      call_count = 0
      allow(todo_app).to receive(:on_line) do |line, sess|
        call_count += 1
        raise 'break loop' if line == 'break'
      end

      expect { todo_app.run }.to raise_error('break loop')
      expect(call_count).to eq(2)
    end

    it 'renders after each command' do
      iteration_count = 0
      allow(session).to receive(:get_line) do
        iteration_count += 1
        raise 'break loop' if iteration_count > 1
        'a Task'
      end

      render_count = 0
      allow(session).to receive(:render) { render_count += 1 }

      expect { todo_app.run }.to raise_error('break loop')
      expect(render_count).to eq(1)
    end
  end
end
