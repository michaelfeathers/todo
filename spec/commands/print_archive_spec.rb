require 'spec_helper'
require 'session'
require 'commands/print_archive'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe PrintArchive do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }

  it 'prints the contents of the archive' do
    archive_content = "2023-06-07 L: Task 1\n2023-06-08 R: Task 2\n"
    f_io.archive_content = archive_content

    PrintArchive.new.run("pa", session)

    # First date gets reverse video, second date is normal
    expected = "\e[7m2023-06-07\e[0m L: Task 1\n2023-06-08 R: Task 2\n"
    expect(f_io.console_output_content).to eq(expected)
  end

  it 'prints an empty archive when there are no saved tasks' do
    f_io.archive_content = ""

    PrintArchive.new.run("pa", session)

    expect(f_io.console_output_content).to eq("")
  end

  it 'toggles reverse video for dates every time the date changes' do
    archive_content = "2023-06-07 Task A\n2023-06-07 Task B\n2023-06-08 Task C\n2023-06-09 Task D\n2023-06-09 Task E\n"
    f_io.archive_content = archive_content

    PrintArchive.new.run("pa", session)

    # First date (2023-06-07): reverse video
    # Same date (2023-06-07): reverse video (no toggle)
    # Second date (2023-06-08): normal (toggle)
    # Third date (2023-06-09): reverse video (toggle)
    # Same date (2023-06-09): reverse video (no toggle)
    expected = "\e[7m2023-06-07\e[0m Task A\n\e[7m2023-06-07\e[0m Task B\n2023-06-08 Task C\n\e[7m2023-06-09\e[0m Task D\n\e[7m2023-06-09\e[0m Task E\n"
    expect(f_io.console_output_content).to eq(expected)
  end
end