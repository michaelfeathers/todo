require 'spec_helper'
require 'session'
require 'commands/section_insert'
require 'fakeappio'

describe SectionInsert do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { SectionInsert.new }

  describe '#matches?' do
    it 'matches "si Work"' do
      expect(command.matches?('si Work')).to be_truthy
    end

    it 'matches multi-word section name' do
      expect(command.matches?('si Work Projects')).to be_truthy
    end

    it 'does not match "si" without argument' do
      expect(command.matches?('si')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('s')).to be_falsey
    end
  end

  describe '#process' do
    it 'moves a task into a section by name' do
      f_io.tasks_content = "#1 Work\nL: existing\nL: orphan\n"
      session.list.cursor_set(2)

      command.run('si Work', session)

      expect(session.list.section_declared_count(0)).to eq(2)
    end

    it 'matches by prefix' do
      f_io.tasks_content = "#1 Work Projects\nL: existing\nL: orphan\n"
      session.list.cursor_set(2)

      command.run('si Work', session)

      expect(session.list.section_declared_count(0)).to eq(2)
    end

    it 'is case-insensitive' do
      f_io.tasks_content = "#1 Work\nL: existing\nL: orphan\n"
      session.list.cursor_set(2)

      command.run('si work', session)

      expect(session.list.section_declared_count(0)).to eq(2)
    end

    it 'does nothing when cursor is on a section header' do
      f_io.tasks_content = "#1 Work\nL: task\n#1 Home\nL: task2\n"
      session.list.cursor_set(0)

      command.run('si Home', session)

      expect(session.list.section_declared_count(0)).to eq(1)
    end

    it 'opens a collapsed section when a task is inserted' do
      f_io.tasks_content = "#1 Work\nL: existing\nL: orphan\n"
      session.list.cursor_set(2)

      command.run('si Work', session)

      expect(session.list.task_at_cursor).to eq('L: orphan')
      # Section should be open (not collapsed) so the inserted task is visible
      window_texts = session.list.window.map { |row| row[2] }
      expect(window_texts).to include("L: orphan\n")
    end

    it 'does nothing when no section matches' do
      f_io.tasks_content = "#1 Work\nL: task\nL: orphan\n"
      session.list.cursor_set(2)

      command.run('si Nope', session)

      expect(session.list.section_declared_count(0)).to eq(1)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to include('si')
    end
  end
end
