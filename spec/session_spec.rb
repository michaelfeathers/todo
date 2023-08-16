

require 'session'


describe Session do
  it 'can create a session' do
    session = Session.new(["L: task 1\n", "L: task 2\n"])

  end
end
