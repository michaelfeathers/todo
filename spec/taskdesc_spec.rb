require 'spec_helper'
require 'day'
require 'taskdesc'

describe TaskDesc do
  describe '.from_line' do
    it 'creates a TaskDesc object from a valid line' do
      line = "2023-06-15 R:"
      task_desc = TaskDesc.from_line(line)

      expect(task_desc).to be_a(TaskDesc)
      expect(task_desc.date).to eq(Day.from_text("2023-06-15"))
      expect(task_desc.task_type).to eq("R")
    end

    it 'handles different task types correctly' do
      lines = [
        "2023-06-15 L: Life task",
        "2023-06-16 W: Work task",
        "2023-06-17 R: Regular task"
      ]

      task_descs = lines.map { |line| TaskDesc.from_line(line) }

      expect(task_descs[0].task_type).to eq("L")
      expect(task_descs[1].task_type).to eq("W")
      expect(task_descs[2].task_type).to eq("R")
    end

    it 'creates a Day object with the correct date' do
      line = "2023-12-31 R: New Year's Eve task"
      task_desc = TaskDesc.from_line(line)

      expect(task_desc.date).to be_a(Day)
      expect(task_desc.date.year).to eq("2023")
      expect(task_desc.date.month).to eq("Dec")
      expect(task_desc.date.day).to eq("31")
    end

    it 'ignores the task description part' do
      line = "2023-06-15 R: This is a long task description with multiple words"
      task_desc = TaskDesc.from_line(line)

      expect(task_desc.date).to eq(Day.from_text("2023-06-15"))
      expect(task_desc.task_type).to eq("R")
      # The TaskDesc object doesn't store the full description
    end

  end
end
