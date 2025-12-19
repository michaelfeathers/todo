require 'spec_helper'
require 'todoupdater'
require 'fakeappio'
require 'day'


describe ToDoUpdater do
  let(:io) { FakeAppIo.new }
  let(:updater) { ToDoUpdater.new(io) }
  let(:today) { Day.from_text('2025-01-15') }

  before do
    io.today_content = today
  end

  describe '#run' do
    context 'when there are no updates' do
      it 'leaves tasks unchanged' do
        io.tasks_content = "Existing task 1\nExisting task 2\n"
        io.update_content = ""

        updater.run

        expect(io.tasks_content).to eq("Existing task 1\nExisting task 2\n")
      end
    end

    context 'when there are due updates' do
      it 'moves due updates to the beginning of tasks' do
        io.tasks_content = "Existing task\n"
        io.update_content = "2025-01-15 Due today\n2025-01-14 Due yesterday\n"

        updater.run

        expect(io.tasks_content).to eq("Due today\nDue yesterday\nExisting task\n")
      end

      it 'strips dates from moved updates' do
        io.tasks_content = ""
        io.update_content = "2025-01-15 Task for today\n"

        updater.run

        expect(io.tasks_content).to eq("Task for today\n")
      end

      it 'removes due updates from the updates file' do
        io.tasks_content = ""
        io.update_content = "2025-01-15 Due today\n2025-01-20 Future task\n"

        updater.run

        expect(io.update_content).to eq(["2025-01-20 Future task\n"])
      end
    end

    context 'when there are non-due updates' do
      it 'keeps non-due updates in the updates file' do
        io.tasks_content = ""
        io.update_content = "2025-01-20 Future task\n"

        updater.run

        expect(io.update_content).to eq(["2025-01-20 Future task\n"])
      end

      it 'sorts non-due updates by date' do
        io.tasks_content = ""
        io.update_content = "2025-01-25 Task C\n2025-01-18 Task A\n2025-01-20 Task B\n"

        updater.run

        expect(io.update_content).to eq([
          "2025-01-18 Task A\n",
          "2025-01-20 Task B\n",
          "2025-01-25 Task C\n"
        ])
      end
    end

    context 'with mixed due and non-due updates' do
      it 'moves only due updates to tasks and keeps non-due sorted' do
        io.tasks_content = "Original task\n"
        io.update_content = "2025-01-10 Past task\n2025-01-15 Today task\n2025-01-20 Future task\n"

        updater.run

        expect(io.tasks_content).to eq("Past task\nToday task\nOriginal task\n")
        expect(io.update_content).to eq(["2025-01-20 Future task\n"])
      end
    end

    context 'when updates have invalid dates' do
      it 'raises an error when trying to sort invalid dates' do
        io.tasks_content = "Original task\n"
        io.update_content = "invalid-date Some task\n2025-01-20 Future task\n"

        expect { updater.run }.to raise_error(Date::Error)
      end

      it 'raises an error even with a single invalid date' do
        io.tasks_content = "Original task\n"
        io.update_content = "invalid-date Some task\n"

        # Invalid dates are treated as non-due (due? returns false)
        # but then sorting fails when trying to parse the invalid date
        expect { updater.run }.to raise_error(Date::Error)
      end
    end
  end

  describe '#due' do
    it 'returns tasks that are due today or in the past' do
      updates = [
        "2025-01-15 Due today\n",
        "2025-01-14 Due yesterday\n",
        "2025-01-20 Future task\n"
      ]

      result = updater.due(updates)

      expect(result).to eq(["Due today\n", "Due yesterday\n"])
    end

    it 'strips dates from due tasks' do
      updates = ["2025-01-15 Task with date\n"]

      result = updater.due(updates)

      expect(result).to eq(["Task with date\n"])
    end

    it 'returns empty array when no tasks are due' do
      updates = ["2025-01-20 Future task\n"]

      result = updater.due(updates)

      expect(result).to be_empty
    end
  end

  describe '#non_due' do
    it 'returns tasks that are not due yet' do
      updates = [
        "2025-01-15 Due today\n",
        "2025-01-20 Future task\n",
        "2025-01-25 Another future task\n"
      ]

      result = updater.non_due(updates)

      expect(result).to eq([
        "2025-01-20 Future task\n",
        "2025-01-25 Another future task\n"
      ])
    end

    it 'returns empty array when all tasks are due' do
      updates = ["2025-01-15 Due today\n"]

      result = updater.non_due(updates)

      expect(result).to be_empty
    end
  end

  describe '#strip_date' do
    it 'removes the first word (date) from the line' do
      line = "2025-01-15 Task description\n"

      result = updater.strip_date(line)

      expect(result).to eq("Task description\n")
    end

    it 'handles multi-word task descriptions' do
      line = "2025-01-15 This is a long task description\n"

      result = updater.strip_date(line)

      expect(result).to eq("This is a long task description\n")
    end

    it 'handles tasks with only a date' do
      line = "2025-01-15\n"

      result = updater.strip_date(line)

      expect(result).to eq("\n")
    end
  end

  describe '#due?' do
    it 'returns true for tasks due today' do
      line = "2025-01-15 Task due today\n"

      expect(updater.due?(line)).to be true
    end

    it 'returns true for tasks due in the past' do
      line = "2025-01-10 Overdue task\n"

      expect(updater.due?(line)).to be true
    end

    it 'returns false for future tasks' do
      line = "2025-01-20 Future task\n"

      expect(updater.due?(line)).to be false
    end

    it 'returns false for lines with invalid dates' do
      line = "invalid-date Some task\n"

      expect(updater.due?(line)).to be false
    end

    it 'returns false for empty lines' do
      line = "\n"

      expect(updater.due?(line)).to be false
    end

    it 'returns false for lines with no date' do
      line = "Just a task with no date\n"

      expect(updater.due?(line)).to be false
    end
  end
end
