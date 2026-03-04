require 'spec_helper'
require 'tasklist'
require 'fakeappio'

describe TaskList, 'sections' do
  let(:io) { FakeAppIo.new }
  let(:task_list) { TaskList.new(io) }

  describe 'section detection' do
    it 'detects a section header' do
      io.tasks_content = "#3 Work Projects\nL: task 1\nL: task 2\nL: task 3\n"
      expect(task_list.section_header?(0)).to be true
    end

    it 'does not detect a regular task as a section header' do
      io.tasks_content = "L: task 1\n"
      expect(task_list.section_header?(0)).to be false
    end

    it 'returns declared count from header' do
      io.tasks_content = "#3 Work Projects\nL: task 1\nL: task 2\nL: task 3\n"
      expect(task_list.section_declared_count(0)).to eq(3)
    end

    it 'returns actual count limited by available tasks' do
      io.tasks_content = "#5 Work\nL: task 1\nL: task 2\n"
      expect(task_list.section_actual_count(0)).to eq(2)
    end

    it 'returns actual count limited by next header' do
      io.tasks_content = "#5 Work\nL: task 1\n#2 Home\nL: task 2\n"
      expect(task_list.section_actual_count(0)).to eq(1)
    end

    it 'returns section range' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: task 3\n"
      expect(task_list.section_range(0)).to eq(0..2)
    end
  end

  describe 'display labels' do
    it 'returns 0-based labels for non-section tasks' do
      io.tasks_content = "L: task 0\nL: task 1\n"
      expect(task_list.display_label(0)).to eq("0")
      expect(task_list.display_label(1)).to eq("1")
    end

    it 'returns legal numbering for section members' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: task 3\n"
      # Section at top-level 0, children are 0.1 and 0.2, task 3 is top-level 1
      expect(task_list.display_label(0)).to eq("0")
      expect(task_list.display_label(0, 0)).to eq("0.1")
      expect(task_list.display_label(0, 1)).to eq("0.2")
      expect(task_list.display_label(1)).to eq("1")
    end

    it 'returns correct labels with multiple sections' do
      io.tasks_content = "#1 A\nL: a1\n#1 B\nL: b1\n"
      expect(task_list.display_label(0)).to eq("0")
      expect(task_list.display_label(0, 0)).to eq("0.1")
      expect(task_list.display_label(1)).to eq("1")
      expect(task_list.display_label(1, 0)).to eq("1.1")
    end

    it 'numbers correctly with tasks before a section' do
      io.tasks_content = "L: first\nL: second\n#2 Work\nL: w1\nL: w2\nL: after\n"
      expect(task_list.display_label(0)).to eq("0")
      expect(task_list.display_label(1)).to eq("1")
      expect(task_list.display_label(2)).to eq("2")
      expect(task_list.display_label(2, 0)).to eq("2.1")
      expect(task_list.display_label(2, 1)).to eq("2.2")
      expect(task_list.display_label(3)).to eq("3")
    end
  end

  describe 'collapse and expand' do
    it 'starts collapsed' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\n"

      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to eq(["0"])
    end

    it 'toggles to expanded then back to collapsed' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\n"
      task_list.cursor_set(0)

      task_list.section_toggle
      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "0.1", "0.2"])

      task_list.section_toggle
      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to eq(["0"])
    end

    it 'hides section members in window when collapsed' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: orphan\n"

      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "1"])
    end

    it 'shows all tasks in window when expanded' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.section_toggle

      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "0.1", "0.2", "1"])
    end
  end

  describe 'cursor navigation with collapsed sections' do
    it 'skips hidden tasks when moving down' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: orphan")
    end

    it 'skips hidden tasks when moving up' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.down
      task_list.up

      expect(task_list.instance_variable_get(:@cursor)).to eq([0, nil])
    end
  end

  describe 'section-aware removal' do
    it 'removes header only when cursor is on header' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\n"
      task_list.cursor_set(0)
      task_list.remove_task_at_cursor

      expect(task_list.count).to eq(2)
      expect(task_list.task_at_cursor).to eq("L: task 1")
    end

    it 'decrements section count when removing a section member' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\n"
      task_list.cursor_set("0.1")
      task_list.remove_task_at_cursor

      expect(task_list.section_declared_count(0)).to eq(1)
    end
  end

  describe 'display_text for section headers' do
    it 'strips the #N prefix from section headers' do
      io.tasks_content = "#3 Work Projects\nL: task 1\n"
      expect(task_list.display_text("#3 Work Projects\n")).to eq("Work Projects\n")
    end

    it 'preserves regular task display_text' do
      io.tasks_content = "L: task 1\n"
      expect(task_list.display_text("L: task 1\n")).to eq("task 1\n")
    end
  end

  describe 'section_insert' do
    it 'moves a task into a section and increments count' do
      io.tasks_content = "#1 Work\nL: existing\nL: orphan\n"
      task_list.cursor_set(1)
      task_list.section_insert(0)

      expect(task_list.section_declared_count(0)).to eq(2)
      expect(task_list.section_actual_count(0)).to eq(2)
    end
  end

  describe 'grab mode with sections' do
    it 'moves section block down as a unit' do
      io.tasks_content = "#1 A\nL: a1\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.grab_toggle
      task_list.down

      expect(task_list.task_at_cursor).to eq("#1 A")
      task_list.save_all
      expect(io.tasks_content).to eq("L: orphan\n#1 A\nL: a1\n")
    end

    it 'moves section block up as a unit' do
      io.tasks_content = "L: orphan\n#1 A\nL: a1\n"
      task_list.cursor_set(1)
      task_list.grab_toggle
      task_list.up

      expect(task_list.task_at_cursor).to eq("#1 A")
      task_list.save_all
      expect(io.tasks_content).to eq("#1 A\nL: a1\nL: orphan\n")
    end

    it 'skips headers when grabbing a regular task down' do
      io.tasks_content = "L: task\n#1 Section\nL: s1\nL: after\n"
      task_list.cursor_set(0)
      task_list.grab_toggle
      task_list.down

      task_list.save_all
      lines = io.tasks_content.split("\n")
      expect(lines[0]).to eq("#1 Section")
      expect(lines[1]).to eq("L: s1")
    end
  end

  describe 'zap with sections' do
    it 'zaps to own position is a no-op' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\nL: orphan\n"
      task_list.cursor_set(1)
      task_list.zap_to_position(1)

      expect(task_list.task_at_cursor).to eq("L: orphan")
    end

    it 'zaps section block as a unit' do
      io.tasks_content = "#1 Work\nL: w1\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.zap_to_position(2)

      task_list.save_all
      lines = io.tasks_content.split("\n")
      expect(lines[0]).to eq("L: orphan")
    end
  end

  describe 'cursor_set with visual labels' do
    it 'sets cursor using dotted notation' do
      io.tasks_content = "#2 Work\nL: task 1\nL: task 2\nL: task 3\n"
      task_list.cursor_set("0.2")

      expect(task_list.task_at_cursor).to eq("L: task 2")
    end

    it 'sets cursor using plain visual label' do
      io.tasks_content = "L: task 0\nL: task 1\n"
      task_list.cursor_set("1")

      expect(task_list.task_at_cursor).to eq("L: task 1")
    end

    it 'sets cursor using integer index' do
      io.tasks_content = "L: task 0\nL: task 1\n"
      task_list.cursor_set(1)

      expect(task_list.task_at_cursor).to eq("L: task 1")
    end
  end
end
