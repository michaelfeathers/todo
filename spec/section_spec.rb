require 'spec_helper'
require 'section'

describe Section do
  describe '#initialize' do
    it 'creates a section with the given name' do
      section = Section.new("Work")
      expect(section.name).to eq("Work")
    end

    it 'starts with no children' do
      section = Section.new("Work")
      expect(section.children).to eq([])
      expect(section.count).to eq(0)
    end

    it 'is a section' do
      section = Section.new("Work")
      expect(section.section?).to be true
    end

    it 'sets text with #0 prefix' do
      section = Section.new("Work")
      expect(section.text).to eq("#0 Work\n")
    end

    it 'starts collapsed' do
      section = Section.new("Projects")
      expect(section.collapsed).to be true
    end
  end

  describe '#add' do
    it 'adds a task to children' do
      section = Section.new("Work")
      task = Task.new("L: task 1\n")
      section.add(task)

      expect(section.children).to eq([task])
      expect(section.count).to eq(1)
    end

    it 'updates text with new count' do
      section = Section.new("Work")
      section.add(Task.new("L: task 1\n"))

      expect(section.text).to eq("#1 Work\n")
    end

    it 'increments count with multiple adds' do
      section = Section.new("Work")
      section.add(Task.new("L: task 1\n"))
      section.add(Task.new("L: task 2\n"))
      section.add(Task.new("L: task 3\n"))

      expect(section.count).to eq(3)
      expect(section.text).to eq("#3 Work\n")
    end
  end

  describe '#remove' do
    it 'removes child at the given index' do
      section = Section.new("Work")
      task1 = Task.new("L: task 1\n")
      task2 = Task.new("L: task 2\n")
      section.add(task1)
      section.add(task2)

      removed = section.remove(0)

      expect(removed).to eq(task1)
      expect(section.children).to eq([task2])
      expect(section.count).to eq(1)
    end

    it 'updates text with new count after remove' do
      section = Section.new("Work")
      section.add(Task.new("L: task 1\n"))
      section.add(Task.new("L: task 2\n"))
      section.remove(0)

      expect(section.text).to eq("#1 Work\n")
    end

    it 'returns nil for out-of-bounds index' do
      section = Section.new("Work")
      expect(section.remove(0)).to be_nil
    end
  end

  describe '#insert' do
    it 'inserts a task at the given index' do
      section = Section.new("Work")
      task1 = Task.new("L: first\n")
      task2 = Task.new("L: second\n")
      task3 = Task.new("L: inserted\n")
      section.add(task1)
      section.add(task2)

      section.insert(1, task3)

      expect(section.children[1]).to eq(task3)
      expect(section.count).to eq(3)
    end

    it 'updates text with new count' do
      section = Section.new("Work")
      section.add(Task.new("L: first\n"))
      section.insert(0, Task.new("L: inserted\n"))

      expect(section.text).to eq("#2 Work\n")
    end
  end

  describe '#count' do
    it 'returns 0 for empty section' do
      section = Section.new("Empty")
      expect(section.count).to eq(0)
    end

    it 'returns the number of children' do
      section = Section.new("Work")
      3.times { |i| section.add(Task.new("L: task #{i}\n")) }
      expect(section.count).to eq(3)
    end
  end

  describe '#name=' do
    it 'allows setting the name' do
      section = Section.new("Old")
      section.name = "New"
      expect(section.name).to eq("New")
    end
  end
end
