require 'spec_helper'
require 'session'
require 'commands/edit_insert'
require 'fakeappio'
require 'testrenderer'

describe EditInsert do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of (session)}

  describe '#run' do
    it 'inserts tokens before the specified position in the current task' do
      f_io.tasks_content = "L: task one two three\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 2 new inserted", session)

      expect(o).to eq([[0, "-", "L: task new inserted one two three\n"]])
    end

    it 'handles insertion at the beginning of the task' do
      f_io.tasks_content = "R: existing task\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 1 prefix", session)

      expect(o).to eq([[0, "-", "R: prefix existing task\n"]])
    end

    it 'handles insertion at the end of the task' do
      f_io.tasks_content = "W: end insertion\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 3 appended text", session)

      expect(o).to eq([[0, "-", "W: end insertion appended text\n"]])
    end

    it 'does not modify the task if the position is out of bounds' do
      f_io.tasks_content = "L: unchanged task\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 10 out of bounds", session)

      expect(o).to eq([[0,"-","L: unchanged task\n"]])
    end

    it 'handles insertion with multiple tokens' do
      f_io.tasks_content = "R: before after\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 2 multiple new tokens here", session)

      expect(o).to eq([[0, "-", "R: before multiple new tokens here after\n"]])
    end

    it 'does nothing when no tokens are provided' do
      f_io.tasks_content = "W: no change\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 2", session)

      expect(o).to eq([[0, "-", "W: no change\n"]])
    end

    it 'preserves the task tag when inserting' do
      f_io.tasks_content = "L: preserve tag\n"
      session.list.cursor_set(0)

      EditInsert.new.run("ei 1 inserted", session)

      expect(o).to eq([[0, "-", "L: inserted preserve tag\n"]])
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
