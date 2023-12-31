

require 'session'
require 'commands'
require 'fakeappio'

describe Session do

  let(:io) { FakeAppIo.new }
  let(:session) { Session.new(io) }

  xit 'does things' do
  end
end


