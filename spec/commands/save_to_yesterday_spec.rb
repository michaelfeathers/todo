require 'spec_helper'
require 'session'
require 'fakeappio'
require 'spec_helper'
require 'commands/save_to_yesterday'
require 'fakeappio'

describe SaveToYesterday do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { SaveToYesterday.new }

  describe '#matches?' do
    it 'returns true for "sy"' do
      expect(command.matches?('sy')).to be true
    end

    it 'returns false for other commands' do
      expect(command.matches?('s')).to be false
      expect(command.matches?('save')).to be false
    end
  end

  describe '#process' do
    before do
      allow(f_io).to receive(:today).and_return(Day.from_text('2023-06-15'))
      f_io.tasks_content = "L: task 1\nR: task 2\nW: task 3\n"
      session.list.cursor_set(1)
    end

    it 'saves the current task to the archive with yesterday\'s date' do
      command.process('sy', session)
      expect(f_io.archive_content).to eq("2023-06-14 R: task 2\n")
    end

    it 'inserts in the right position' do
      f_io.tasks_content = "R: task prior\n"
      f_io.archive_content = "2023-06-15 R: task existing\n"
      session = Session.from_ios(f_io, f_io)
      command.process('sy', session)
      expect(f_io.archive_content).to eq("2023-06-14 R: task prior\n2023-06-15 R: task existing\n")
    end

    it 'removes the saved task from the task list' do
      command.process('sy', session)
      session.save
      expect(f_io.tasks_content).to eq("L: task 1\nW: task 3\n")
    end

    it 'does nothing if the task list is empty' do
      f_io.tasks_content = ""
      f_io.archive_content = ""
      session = Session.from_ios(f_io, f_io)
      command.process('sy', session)
      expect(f_io.archive_content).to be_empty
    end

    it 'does nothing if the cursor is on an empty line' do
      f_io.tasks_content = "L: task 1\n\nW: task 3\n"
      session = Session.from_ios(f_io, f_io)
      session.list.cursor_set(1)
      command.process('sy', session)
      expect(f_io.archive_content).to be_empty
      expect(f_io.tasks_content).to eq("L: task 1\n\nW: task 3\n")
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      expect(command.description.name).to eq('sy')
      expect(command.description.line).to eq('save task at cursor to archive with yesterday\'s date')
    end
  end
end
