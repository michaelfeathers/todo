require 'spec_helper'
require 'session'
require 'commands/tag_tallies'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe TagTallies do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }

  describe '#run' do
    it 'displays tag tallies and untagged count' do
      f_io.tasks_content = "L: task 1\nR: task 2\nR: task 3\nW: task 4\nL: task 5\ntask 6\ntask 7\n"

      TagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          2")
      expect(f_io.console_output_content).to include("   R:          2")
      expect(f_io.console_output_content).to include("   W:          1")
      expect(f_io.console_output_content).to include("   Untagged    2")
    end

    it 'returns to the prompt after displaying tag tallies' do
      f_io.tasks_content = "L: task 1\nR: task 2\nR: task 3\nW: task 4\nL: task 5\ntask 6\ntask 7\n"

      expect(f_io).to receive(:get_from_console)

      TagTallies.new.run('tt', session)
    end

    it 'displays only untagged count when no tags are present' do
      f_io.tasks_content = "task 1\ntask 2\ntask 3\n"

      TagTallies.new.run('tt', session)

      expect(f_io.console_output_content).not_to include("L:")
      expect(f_io.console_output_content).not_to include("R:")
      expect(f_io.console_output_content).not_to include("W:")
      expect(f_io.console_output_content).to include("   Untagged    3")
    end

    it 'displays tag tallies correctly when only one tag is present' do
      f_io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"

      TagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          3")
      expect(f_io.console_output_content).to include("   Untagged    0")
    end

    it 'does not count empty lines as untagged tasks' do
      f_io.tasks_content = "L: task 1\n\nR: task 2\n\n\n"

      TagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          1")
      expect(f_io.console_output_content).to include("   R:          1")
      expect(f_io.console_output_content).to include("   Untagged    0")
    end
  end

  describe '#matches?' do
    it 'matches a command with "tt"' do
      expect(TagTallies.new.matches?('tt')).to be_truthy
    end

    it 'does not match a command other than "tt"' do
      expect(TagTallies.new.matches?('xx')).to be_falsey
    end
  end
end