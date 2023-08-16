

require 'session'


describe Session do
  it 'finds simple text' do
    session = Session.new(["L: task AA\n", "L: task BB\n"])
    expect(session.find("AA")).to eq([" 0 L: task AA\n"])
  end

  it 'ignores case when it finds' do
    session = Session.new(["L: task A\n", "L: task B\n"])
    expect(session.find("b")).to eq([" 1 L: task B\n"])
  end
end
