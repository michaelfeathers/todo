require 'spec_helper'
require 'session'
require 'commands/surface'
require 'fakeappio'


describe Surface do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:command) { Surface.new }

  describe '#matches?' do
    it 'matches "su" without arguments' do
      expect(command.matches?('su')).to be_truthy
    end

    it 'matches "su" with a non-negative integer' do
      expect(command.matches?('su 1')).to be_truthy
      expect(command.matches?('su 5')).to be_truthy
      expect(command.matches?('su 0')).to be_truthy
      expect(command.matches?('su 100')).to be_truthy
    end

    it 'does not match "su" with negative integer' do
      expect(command.matches?('su -1')).to be_falsey
    end

    it 'does not match "su" with non-integer argument' do
      expect(command.matches?('su abc')).to be_falsey
      expect(command.matches?('su 1.5')).to be_falsey
    end

    it 'does not match "su" with multiple arguments' do
      expect(command.matches?('su 1 2')).to be_falsey
    end

    it 'does not match other commands' do
      expect(command.matches?('s')).to be_falsey
      expect(command.matches?('surface')).to be_falsey
    end
  end

  describe '#process' do
    context 'with default argument (1 task)' do
      it 'moves one random task from background to foreground' do
        f_io.tasks_content = "F: task 1\nF: task 2\n"
        b_io.tasks_content = "B: task A\nB: task B\nB: task C\n"

        command.run('su', session)

        # Foreground should have 3 tasks + 1 blank line = 4 items
        expect(session.foreground_tasks.count).to eq(4)
        # Background should have 2 tasks
        expect(session.background_tasks.count).to eq(2)

        # First task should be from background, second should be blank
        foreground_window = session.foreground_tasks.window
        expect(foreground_window[0][2]).to match(/^B:/)
        expect(foreground_window[1][2]).to eq("\n")
        # Original foreground tasks should follow
        expect(foreground_window[2][2]).to eq("F: task 1\n")
      end

      it 'ends on the original list (foreground)' do
        f_io.tasks_content = "F: task 1\n"
        b_io.tasks_content = "B: task A\n"

        command.run('su', session)

        expect(session.list).to eq(session.foreground_tasks)
      end
    end

    context 'with explicit count argument' do
      it 'moves specified number of tasks from background' do
        f_io.tasks_content = "F: task 1\n"
        b_io.tasks_content = "B: task A\nB: task B\nB: task C\nB: task D\n"

        command.run('su 3', session)

        # Foreground: 3 background tasks + 1 blank + 1 original = 5
        expect(session.foreground_tasks.count).to eq(5)
        # Background: 4 - 3 = 1
        expect(session.background_tasks.count).to eq(1)

        # First 3 tasks should be from background
        foreground_window = session.foreground_tasks.window
        expect(foreground_window[0][2]).to match(/^B:/)
        expect(foreground_window[1][2]).to match(/^B:/)
        expect(foreground_window[2][2]).to match(/^B:/)
        # Fourth should be blank
        expect(foreground_window[3][2]).to eq("\n")
        # Fifth should be original foreground task
        expect(foreground_window[4][2]).to eq("F: task 1\n")
      end

      it 'surfaces all background tasks if count exceeds available' do
        f_io.tasks_content = "F: task 1\n"
        b_io.tasks_content = "B: task A\nB: task B\n"

        command.run('su 10', session)

        # Foreground: 2 background tasks + 1 blank + 1 original = 4
        expect(session.foreground_tasks.count).to eq(4)
        # Background should be empty
        expect(session.background_tasks.count).to eq(0)
      end

      it 'does nothing when count is 0' do
        f_io.tasks_content = "F: task 1\n"
        b_io.tasks_content = "B: task A\n"

        command.run('su 0', session)

        # Nothing should change
        expect(session.foreground_tasks.count).to eq(1)
        expect(session.background_tasks.count).to eq(1)
      end
    end

    context 'with empty background' do
      it 'does nothing when background is empty' do
        f_io.tasks_content = "F: task 1\nF: task 2\n"
        b_io.tasks_content = ""

        command.run('su 3', session)

        # Foreground should remain unchanged
        expect(session.foreground_tasks.count).to eq(2)
        expect(session.background_tasks.count).to eq(0)
      end
    end

    context 'with empty foreground' do
      it 'adds tasks to empty foreground' do
        f_io.tasks_content = ""
        b_io.tasks_content = "B: task A\nB: task B\n"

        command.run('su 2', session)

        # Foreground: 2 background tasks + 1 blank = 3
        expect(session.foreground_tasks.count).to eq(3)
        expect(session.background_tasks.count).to eq(0)

        foreground_window = session.foreground_tasks.window
        expect(foreground_window[0][2]).to match(/^B:/)
        expect(foreground_window[1][2]).to match(/^B:/)
        expect(foreground_window[2][2]).to eq("\n")
      end
    end

    context 'when starting from background list' do
      it 'returns to background list after surfacing' do
        f_io.tasks_content = "F: task 1\n"
        b_io.tasks_content = "B: task A\nB: task B\n"

        # Switch to background first
        session.switch_lists

        command.run('su 1', session)

        # Should return to background
        expect(session.list).to eq(session.background_tasks)
      end
    end

    context 'randomness' do
      it 'selects tasks randomly from background' do
        f_io.tasks_content = ""
        # Create many background tasks
        background_tasks = 10.times.map { |i| "B: task #{i}\n" }
        b_io.tasks_content = background_tasks.join

        # Surface 5 tasks
        command.run('su 5', session)

        # Verify we got 5 tasks (not checking which specific ones due to randomness)
        expect(session.foreground_tasks.count).to eq(6)  # 5 tasks + 1 blank
        expect(session.background_tasks.count).to eq(5)

        # Verify the blank line is at position 5 (index 5)
        foreground_window = session.foreground_tasks.window
        expect(foreground_window[5][2]).to eq("\n")
      end
    end
  end

  describe '#description' do
    it 'returns the correct command description' do
      desc = command.description
      expect(desc.name).to eq('su [n]')
      expect(desc.line).to eq('surface n random tasks from background to foreground (default 1)')
    end
  end
end
