require 'spec_helper'
require 'session'
require 'commands/quit'
require 'fakeappio'

describe Quit do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { Quit.new }

  describe '#matches?' do
    it 'matches "q"' do
      expect(command.matches?('q')).to be_truthy
    end

    it 'does not match "q" with arguments' do
      expect(command.matches?('q arg')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('quit')).to be_falsey
      expect(command.matches?('x')).to be_falsey
    end
  end

  describe '#process' do
    it 'saves the session before exiting' do
      f_io.tasks_content = "Task 1\nTask 2"

      # Stub exit to prevent actually exiting
      allow(command).to receive(:exit)

      expect(session).to receive(:save)

      command.run('q', session)
    end

    it 'calls exit' do
      # Stub exit to prevent actually exiting
      expect(command).to receive(:exit)

      command.run('q', session)
    end

    it 'saves before calling exit' do
      # Verify the order of operations
      allow(command).to receive(:exit)

      expect(session).to receive(:save).ordered
      expect(command).to receive(:exit).ordered

      command.run('q', session)
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('q')
      expect(desc.line).to eq('save and quit')
    end
  end
end
