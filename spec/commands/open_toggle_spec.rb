require 'spec_helper'
require 'session'
require 'commands/open_toggle'
require 'fakeappio'
require 'testrenderer'

describe OpenToggle do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { OpenToggle.new }

  describe '#matches?' do
    it 'matches ot' do
      expect(command.matches?('ot')).to be true
    end

    it 'does not match other input' do
      expect(command.matches?('ott')).to be false
      expect(command.matches?('o')).to be false
    end
  end

  describe '#process' do
    it 'opens all sections when all are collapsed' do
      f_io.tasks_content = "#2 A\nL: a1\nL: a2\n#1 B\nL: b1\n"
      command.run('ot', session)

      labels = session.list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "0.1", "0.2", "1", "1.1"])
    end

    it 'closes all sections when all are open' do
      f_io.tasks_content = "#2 A\nL: a1\nL: a2\n#1 B\nL: b1\n"
      command.run('ot', session)
      command.run('ot', session)

      labels = session.list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "1"])
    end

    it 'opens all when some are open and some collapsed' do
      f_io.tasks_content = "#1 A\nL: a1\n#1 B\nL: b1\n"
      session.list.cursor_set(0)
      session.list.section_toggle  # open A only

      command.run('ot', session)

      labels = session.list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "0.1", "1", "1.1"])
    end

    it 'does nothing when there are no sections' do
      f_io.tasks_content = "L: task 1\nL: task 2\n"
      command.run('ot', session)

      labels = session.list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "1"])
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      expect(command.description.name).to eq('ot')
    end
  end
end
