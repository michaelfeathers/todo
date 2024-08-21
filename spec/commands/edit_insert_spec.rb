require 'spec_helper'
require 'session'
require 'commands/edit_insert'
require 'fakeappio'

describe EditInsert do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'inserts tokens before the specified position in the current task' do
      f_io.actions_content = "L: task one two three\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 2 new inserted", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - L: task new inserted one two three\n\n")
    end

    it 'handles insertion at the beginning of the task' do
      f_io.actions_content = "R: existing task\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 1 prefix", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - R: prefix existing task\n\n")
    end

    it 'handles insertion at the end of the task' do
      f_io.actions_content = "W: end insertion\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 3 appended text", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - W: end insertion appended text\n\n")
    end

    it 'does not modify the task if the position is out of bounds' do
      f_io.actions_content = "L: unchanged task\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 10 out of bounds", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - L: unchanged task\n\n")
    end

    it 'handles insertion with multiple tokens' do
      f_io.actions_content = "R: before after\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 2 multiple new tokens here", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - R: before multiple new tokens here after\n\n")
    end

    it 'does nothing when no tokens are provided' do
      f_io.actions_content = "W: no change\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 2", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - W: no change\n\n")
    end

    it 'preserves the task tag when inserting' do
      f_io.actions_content = "L: preserve tag\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 1 inserted", session)
      session.list.render

      expect(f_io.console_output_content).to eq("\n\n 0 - L: inserted preserve tag\n\n")
    end
  end

  describe '#matches?' do
    it 'matches a command with "ei" followed by a number and text' do
      expect(EditInsert.new.matches?('ei 2 inserted text')).to be_truthy
    end

    it 'does not match a command without "ei"' do
      expect(EditInsert.new.matches?('e 2 text')).to be_falsey
    end

    it 'does not match a command with "ei" but no position' do
      expect(EditInsert.new.matches?('ei text')).to be_falsey
    end

    it 'does not match a command with "ei" and position but no text' do
      expect(EditInsert.new.matches?('ei 2')).to be_falsey
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      expect(EditInsert.new.description.name).to eq('ei position text')
      expect(EditInsert.new.description.line).to eq('insert text before the specified position in the current task')
    end
  end
end
