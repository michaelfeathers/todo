require 'spec_helper'
require 'session'
require 'commands/find_in_archive'
require 'fakeappio'
require 'testrenderer'

describe FindInArchive do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'finds matching lines in the archive' do
    f_io.archive_content = "2023-06-07 L: Buy groceries\n2023-06-08 R: Fix bug\n2023-06-09 L: Buy shoes\n"

    FindInArchive.new.run("fa Buy", session)

    expect(f_io.console_output_content).to include("Buy groceries")
    expect(f_io.console_output_content).to include("Buy shoes")
    expect(f_io.console_output_content).to include("2 found")
  end

  it 'is case insensitive' do
    f_io.archive_content = "2023-06-07 L: Buy groceries\n2023-06-08 R: Fix bug\n"

    FindInArchive.new.run("fa buy", session)

    expect(f_io.console_output_content).to include("Buy groceries")
    expect(f_io.console_output_content).to include("1 found")
  end

  it 'reports zero matches when nothing found' do
    f_io.archive_content = "2023-06-07 L: Buy groceries\n"

    FindInArchive.new.run("fa xyz", session)

    expect(f_io.console_output_content).to include("0 found")
  end

  it 'does not match without a search term' do
    expect(FindInArchive.new.matches?("fa")).to be false
  end

  it 'matches with a search term' do
    expect(FindInArchive.new.matches?("fa something")).to be true
  end
end
