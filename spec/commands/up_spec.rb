require 'spec_helper'
require_relative '../../lib/commands/up'
require_relative '../../lib/session'
require_relative '../../spec/fakeappio'

RSpec.describe Up do
  let(:command) { Up.new }
  let(:session) { Session.from_ios(FakeAppIo.new, FakeAppIo.new) }

  describe '#description' do
    it 'returns the correct command description' do
      expect(command.description).to eq(CommandDesc.new("u", "move cursor up"))
    end
  end

  describe '#matches?' do
    it 'returns true for "u"' do
      expect(command.matches?("u")).to be true
    end

    it 'returns false for other inputs' do
      expect(command.matches?("up")).to be false
      expect(command.matches?("down")).to be false
    end
  end

  describe '#process' do
    it 'calls up on the list in the session' do
      list = double('list')
      allow(session).to receive(:on_list).and_yield(list)
      expect(list).to receive(:up)

      command.process("u", session)
    end
  end
end
