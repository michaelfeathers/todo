require 'spec_helper'
require 'session'
require 'commands/display_edit'
require 'fakeappio'


describe DisplayEdit do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'displays the line at the cursor with numbered columns' do
    f_io.tasks_content = "L: This is a test line\n"
    session.list.cursor_set(0)

    DisplayEdit.new.run("ed", session)

    expected_output = "L: This is a test line\n" +
                      "   1    2  3 4    5    \n\n"
    expect(f_io.console_output_content).to eq(expected_output)
  end

  it 'returns to the prompt after displaying the numbered line' do
    f_io.tasks_content = "W: Yet another test\n"
    session.list.cursor_set(0)

    expect(f_io).to receive(:get_from_console)

    DisplayEdit.new.run("ed", session)
  end

  it 'displays an empty line if the cursor is on an empty line' do
    f_io.tasks_content = "\n"
    session.list.cursor_set(0)

    DisplayEdit.new.run("ed", session)

    expect(f_io.console_output_content).to eq("")
  end

  describe '#matches?' do
    it 'matches a command with "ed"' do
      expect(DisplayEdit.new.matches?('ed')).to be_truthy
    end

    it 'does not match a command other than "ed"' do
      expect(DisplayEdit.new.matches?('zz')).to be_falsey
    end
  end
end
