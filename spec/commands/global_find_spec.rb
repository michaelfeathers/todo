require 'spec_helper'
require 'commands/global_find'
require 'session'
require 'fakeappio'

describe GlobalFind do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'finds tasks containing the specified text in the foreground list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      GlobalFind.new.run('gf 2', session)

      expect(f_io.console_output_content).to include("Task 2")
    end

    it 'finds tasks containing the specified text in the background list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      GlobalFind.new.run('gf B', session)

      expect(f_io.console_output_content).to include("Background:")
      expect(f_io.console_output_content).to include("Task B")
    end

    it 'finds tasks containing the specified text in both lists' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task 2\nTask B\nTask C\n"

      GlobalFind.new.run('gf 2', session)

      expect(f_io.console_output_content).to include("Task 2")
      expect(f_io.console_output_content).to include("Background:")
      expect(f_io.console_output_content).to include("Task 2")
    end

    it 'does not find tasks if the specified text is not present in either list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      GlobalFind.new.run('gf X', session)

      expect(f_io.console_output_content).not_to include("Task")
    end

    it 'returns to the prompt after displaying the search results' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      expect(f_io).to receive(:get_from_console)

      GlobalFind.new.run('gf 2', session)
    end
  end

  describe '#matches?' do
    it 'matches a command with "gf" followed by text' do
      expect(GlobalFind.new.matches?('gf text')).to be_truthy
    end

    it 'does not match a command without "gf"' do
      expect(GlobalFind.new.matches?('text')).to be_falsey
    end

    it 'does not match a command with "gf" but no text' do
      expect(GlobalFind.new.matches?('gf')).to be_falsey
    end
  end
end
