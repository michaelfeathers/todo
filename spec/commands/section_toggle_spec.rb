require 'spec_helper'
require 'session'
require 'commands/section_toggle'
require 'fakeappio'
require 'testrenderer'

describe SectionToggle do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { SectionToggle.new }

  describe '#matches?' do
    it 'matches empty input' do
      expect(command.matches?('')).to be_truthy
    end

    it 'matches whitespace-only input' do
      expect(command.matches?('  ')).to be_truthy
    end

    it 'does not match non-empty input' do
      expect(command.matches?('d')).to be_falsey
    end
  end

  describe '#run' do
    it 'does nothing when cursor is not on a section header' do
      f_io.tasks_content = "L: task 1\nL: task 2\n"
      result = CommandResult.new
      command.run('', session, result)

      expect(result.match_count).to eq(0)
    end

    it 'expands when cursor is on a collapsed section header' do
      f_io.tasks_content = "#2 Work\nL: task 1\nL: task 2\n"
      session.list.cursor_set(0)

      result = CommandResult.new
      command.run('', session, result)

      expect(result.match_count).to eq(1)
      labels = session.list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "0.1", "0.2"])
    end

    it 'collapses on second toggle' do
      f_io.tasks_content = "#2 Work\nL: task 1\nL: task 2\n"
      session.list.cursor_set(0)

      command.run('', session)
      command.run('', session)

      labels = session.list.window.map { |label, _, _| label }
      expect(labels).to eq(["0"])
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('(enter)')
    end
  end
end
