require 'spec_helper'
require 'session'
require 'commands/edit'
require 'fakeappio'

describe Edit do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'edits the task at the cursor' do
      f_io.tasks_content = "L: old task\nR: another task\n"
      session.list.cursor_set(0)

      Edit.new.run("e new task", session)
      session.render_naked

      expect(f_io.console_output_content).to include(" 0 - L: new task\n")
    end

    it 'preserves the tag when editing' do
      f_io.tasks_content = "W: old work task\nR: another task\n"
      session.list.cursor_set(0)

      Edit.new.run("e updated work task", session)
      session.render_naked

      expect(f_io.console_output_content).to include(" 0 - W: updated work task\n")
    end

    it 'does nothing when the task list is empty' do
      f_io.tasks_content = ""

      Edit.new.run("e new task", session)
      session.render_naked

      expect(f_io.console_output_content).to eq("\n\n\n")
    end

    it 'does nothing when editing an empty line' do
      f_io.tasks_content = "L: task 1\n\nR: task 2\n"
      session.list.cursor_set(1)

      Edit.new.run("e new task", session)
      session.render_naked

      expect(f_io.console_output_content).to include(" 1 - \n")
    end

    it 'handles multiple words in the edit command' do
      f_io.tasks_content = "L: old single word\n"
      session.list.cursor_set(0)

      Edit.new.run("e new multiple word task", session)
      session.render_naked

      expect(f_io.console_output_content).to include(" 0 - L: new multiple word task\n")
    end
  end

  describe '#matches?' do
    it 'matches a command starting with "e" followed by text' do
      expect(Edit.new.matches?('e new task')).to be_truthy
    end

    it 'does not match a command without "e"' do
      expect(Edit.new.matches?('new task')).to be_falsey
    end

    it 'does not match a command with only "e"' do
      expect(Edit.new.matches?('e')).to be_falsey
    end

    it 'matches a command with "e" and multiple words' do
      expect(Edit.new.matches?('e new multiple word task')).to be_truthy
    end
  end
end
