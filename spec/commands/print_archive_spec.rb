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

    expect(f_io.console_output_content).to eq(archive_content)
  end

  it 'prints an empty archive when there are no saved tasks' do
    f_io.archive_content = ""

    PrintArchive.new.run("pa", session)

    expect(f_io.console_output_content).to eq("")
  end
end