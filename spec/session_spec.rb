

require 'session'
require 'commands'
require 'fakeappio'

describe Session do

  before(:each) do
    @io = FakeAppIo.new
    @session = Session.new(@io, @io)
  end

  it 'updates the existing command log' do
    @io.log_content = "c,12\nz,10"
    @session = Session.new(@io, @io) 
    @session.log_command("z")
    expect(@io.log_content).to eq("c,12\nz,11")
  end

  it 'adds to existing command log' do
    @io.log_content = "c,12\nz,10\n"
    @session = Session.new(@io, @io) 
    @session.log_command("t")
    expect(@io.log_content).to eq("c,12\nz,10\nt,1")
  end

  it 'adds to an empty command log' do
    @io.log_content = ""
    @session = Session.new(@io, @io) 
    @session.log_command("t")
    expect(@io.log_content).to eq("t,1")
  end

end


