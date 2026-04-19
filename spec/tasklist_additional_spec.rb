require 'spec_helper'
require 'tasklist'
require 'fakeappio'

describe TaskList do
  let(:io) { FakeAppIo.new }
  let(:task_list) { TaskList.new(io) }

  describe '#add_section' do
    it 'adds a section at the top of the list' do
      io.tasks_content = "L: task 1\n"
      task_list.add_section("Work")

      expect(task_list.section_header?(0)).to be true
      expect(task_list.count).to eq(2)
    end

    it 'sets cursor to the new section' do
      io.tasks_content = "L: task 1\n"
      task_list.cursor_set(0)
      task_list.add_section("Projects")

      expect(task_list.task_at_cursor).to include("Projects")
    end

    it 'adds section to empty list' do
      io.tasks_content = ""
      task_list.add_section("New Section")

      expect(task_list.count).to eq(1)
      expect(task_list.section_header?(0)).to be true
    end
  end

  describe '#detail_toggle' do
    it 'shows tags in detail mode' do
      io.tasks_content = "L: task one\n"
      expect(task_list.display_text("L: task one\n")).to eq("task one\n")

      task_list.detail_toggle
      expect(task_list.display_text("L: task one\n")).to eq("L: task one\n")
    end

    it 'indents untagged tasks in detail mode' do
      io.tasks_content = "untagged task\n"
      task_list.detail_toggle

      expect(task_list.display_text("untagged task\n")).to eq("   untagged task\n")
    end

    it 'toggles back to normal mode' do
      io.tasks_content = "L: task\n"
      task_list.detail_toggle
      task_list.detail_toggle

      expect(task_list.display_text("L: task\n")).to eq("task\n")
    end
  end

  describe '#page_down' do
    it 'advances to next page when there are enough items' do
      io.tasks_content = 50.times.map { |i| "L: task #{i}\n" }.join
      task_list.page_down

      labels = task_list.window.map { |label, _, _| label }
      expect(labels.first).to eq("40")
    end

    it 'does not advance past the last page' do
      io.tasks_content = 50.times.map { |i| "L: task #{i}\n" }.join
      5.times { task_list.page_down }

      labels = task_list.window.map { |label, _, _| label }
      expect(labels.first).to eq("40")
    end

    it 'does nothing with fewer items than page size' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      task_list.page_down

      labels = task_list.window.map { |label, _, _| label }
      expect(labels.first).to eq("0")
    end
  end

  describe '#page_up' do
    it 'goes back to previous page' do
      io.tasks_content = 50.times.map { |i| "L: task #{i}\n" }.join
      task_list.page_down
      task_list.page_up

      labels = task_list.window.map { |label, _, _| label }
      expect(labels.first).to eq("0")
    end

    it 'does not go before the first page' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      task_list.page_up

      labels = task_list.window.map { |label, _, _| label }
      expect(labels.first).to eq("0")
    end
  end

  describe '#find_section_by_name' do
    it 'finds a section by name prefix' do
      io.tasks_content = "L: task\n#1 Work Projects\nL: w1\n#1 Personal\nL: p1\n"
      expect(task_list.find_section_by_name("Work")).to eq(1)
    end

    it 'is case-insensitive' do
      io.tasks_content = "#1 Work\nL: w1\n"
      expect(task_list.find_section_by_name("work")).to eq(0)
    end

    it 'returns nil when no section matches' do
      io.tasks_content = "#1 Work\nL: w1\n"
      expect(task_list.find_section_by_name("Home")).to be_nil
    end

    it 'returns nil when there are no sections' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      expect(task_list.find_section_by_name("Work")).to be_nil
    end
  end

  describe '#sections_toggle_all' do
    it 'expands all sections when some are collapsed' do
      io.tasks_content = "#1 Work\nL: w1\n#1 Personal\nL: p1\n"
      task_list.sections_toggle_all

      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to include("0.1")
      expect(labels).to include("1.1")
    end

    it 'collapses all sections when all are expanded' do
      io.tasks_content = "#1 Work\nL: w1\n#1 Personal\nL: p1\n"
      task_list.sections_toggle_all  # expand all
      task_list.sections_toggle_all  # collapse all

      labels = task_list.window.map { |label, _, _| label }
      expect(labels).to eq(["0", "1"])
    end

    it 'does nothing when there are no sections' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      expect { task_list.sections_toggle_all }.not_to raise_error
    end
  end

  describe '#retag' do
    it 'retags a tagged task' do
      io.tasks_content = "L: old task\n"
      task_list.retag("W")

      expect(task_list.task_at_cursor).to eq("W: old task")
    end

    it 'adds a tag to an untagged task' do
      io.tasks_content = "some task\n"
      task_list.retag("L")

      expect(task_list.task_at_cursor).to eq("L: some task")
    end

    it 'does nothing on an empty list' do
      io.tasks_content = ""
      expect { task_list.retag("W") }.not_to raise_error
    end
  end

  describe '#edit_insert' do
    it 'inserts tokens at the specified position' do
      io.tasks_content = "L: one three\n"
      task_list.edit_insert(1, ["two"])

      expect(task_list.task_at_cursor).to eq("L: one two three")
    end

    it 'inserts at the end when position exceeds task size' do
      io.tasks_content = "L: one\n"
      task_list.edit_insert(10, ["two"])

      expect(task_list.task_at_cursor).to eq("L: one two")
    end

    it 'does nothing with empty tokens' do
      io.tasks_content = "L: task\n"
      task_list.edit_insert(0, [])

      expect(task_list.task_at_cursor).to eq("L: task")
    end

    it 'does nothing with negative position' do
      io.tasks_content = "L: task\n"
      task_list.edit_insert(-1, ["new"])

      expect(task_list.task_at_cursor).to eq("L: task")
    end

    it 'preserves tag when inserting' do
      io.tasks_content = "W: one two\n"
      task_list.edit_insert(0, ["zero"])

      expect(task_list.task_at_cursor).to eq("W: zero one two")
    end
  end

  describe '#edit_replace' do
    it 'replaces token at position' do
      io.tasks_content = "L: one two three\n"
      task_list.edit_replace(1, ["TWO"])

      expect(task_list.task_at_cursor).to eq("L: one TWO three")
    end

    it 'deletes token when new_tokens is empty' do
      io.tasks_content = "L: one two three\n"
      task_list.edit_replace(1, [])

      expect(task_list.task_at_cursor).to eq("L: one three")
    end

    it 'preserves tag when replacing' do
      io.tasks_content = "W: old text\n"
      task_list.edit_replace(0, ["new"])

      expect(task_list.task_at_cursor).to eq("W: new text")
    end
  end

  describe '#display_text' do
    it 'strips section prefix' do
      io.tasks_content = ""
      expect(task_list.display_text("#5 My Section\n")).to eq("My Section\n")
    end

    it 'strips tag from normal tasks' do
      io.tasks_content = ""
      expect(task_list.display_text("L: my task\n")).to eq("my task\n")
    end

    it 'preserves untagged tasks' do
      io.tasks_content = ""
      expect(task_list.display_text("my task\n")).to eq("my task\n")
    end

    it 'preserves tag-only tasks' do
      io.tasks_content = ""
      expect(task_list.display_text("L:\n")).to eq("L:\n")
    end
  end

  describe '#iterative_find_init' do
    it 'sets cursor to first matching task' do
      io.tasks_content = "L: alpha\nL: beta\nL: gamma\n"
      task_list.iterative_find_init("beta")

      expect(task_list.task_at_cursor).to eq("L: beta")
    end

    it 'is case insensitive' do
      io.tasks_content = "L: alpha\nL: BETA\n"
      task_list.iterative_find_init("beta")

      expect(task_list.task_at_cursor).to eq("L: BETA")
    end
  end

  describe '#iterative_find_continue' do
    it 'moves to next match' do
      io.tasks_content = "L: alpha task\nL: beta\nL: alpha again\n"
      task_list.iterative_find_init("alpha")
      task_list.iterative_find_continue

      expect(task_list.task_at_cursor).to eq("L: alpha again")
    end

    it 'does nothing without a prior search' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      task_list.iterative_find_continue

      expect(task_list.task_at_cursor).to eq("L: task 1")
    end

    it 'stays at current position when no more matches' do
      io.tasks_content = "L: alpha\nL: beta\n"
      task_list.iterative_find_init("alpha")
      task_list.iterative_find_continue

      expect(task_list.task_at_cursor).to eq("L: alpha")
    end
  end

  describe '#zap_to_position' do
    it 'moves a task to a new position' do
      io.tasks_content = "L: task 0\nL: task 1\nL: task 2\n"
      task_list.cursor_set(0)
      task_list.zap_to_position(2)

      task_list.save_all
      lines = io.tasks_content.split("\n")
      expect(lines[2]).to eq("L: task 0")
    end

    it 'handles string position' do
      io.tasks_content = "L: task 0\nL: task 1\nL: task 2\n"
      task_list.cursor_set(0)
      task_list.zap_to_position("2")

      task_list.save_all
      lines = io.tasks_content.split("\n")
      expect(lines[2]).to eq("L: task 0")
    end

    it 'ignores dotted string positions' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\nL: orphan\n"
      task_list.cursor_set(1)
      task_list.zap_to_position("0.1")

      # Should be a no-op for dotted positions at top level
      expect(task_list.task_at_cursor).to eq("L: orphan")
    end

    it 'zaps a section child out of the section' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\nL: orphan\n"
      task_list.cursor_set("0.1")
      task_list.zap_to_position(1)

      task_list.save_all
      expect(io.tasks_content).to include("L: w1")
    end
  end

  describe '#grab mode with children' do
    it 'swaps children within a section when grabbing down' do
      io.tasks_content = "#2 Work\nL: first\nL: second\n"
      task_list.cursor_set(0)
      task_list.section_toggle  # expand
      task_list.cursor_set("0.1")
      task_list.grab_toggle
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: first")
      task_list.save_all
      lines = io.tasks_content.split("\n")
      expect(lines[1]).to eq("L: second")
      expect(lines[2]).to eq("L: first")
    end

    it 'swaps children within a section when grabbing up' do
      io.tasks_content = "#2 Work\nL: first\nL: second\n"
      task_list.cursor_set(0)
      task_list.section_toggle  # expand
      task_list.cursor_set("0.2")
      task_list.grab_toggle
      task_list.up

      expect(task_list.task_at_cursor).to eq("L: second")
      task_list.save_all
      lines = io.tasks_content.split("\n")
      expect(lines[1]).to eq("L: second")
      expect(lines[2]).to eq("L: first")
    end

    it 'does not grab child past first position' do
      io.tasks_content = "#2 Work\nL: first\nL: second\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set("0.1")
      task_list.grab_toggle
      task_list.up

      expect(task_list.task_at_cursor).to eq("L: first")
    end

    it 'does not grab child past last position' do
      io.tasks_content = "#2 Work\nL: first\nL: second\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set("0.2")
      task_list.grab_toggle
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: second")
    end
  end

  describe '#down navigation into expanded sections' do
    it 'navigates into expanded section children' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.section_toggle  # expand
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: w1")
    end

    it 'navigates from one child to the next child' do
      io.tasks_content = "#3 Work\nL: w1\nL: w2\nL: w3\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set("0.1")
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: w2")
    end

    it 'navigates from last child to next top-level item' do
      io.tasks_content = "#1 Work\nL: w1\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set("0.1")
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: orphan")
    end

    it 'does not go past the last item' do
      io.tasks_content = "L: only\n"
      task_list.down

      expect(task_list.task_at_cursor).to eq("L: only")
    end
  end

  describe '#up navigation with expanded sections' do
    it 'navigates from top-level to last child of previous expanded section' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\nL: orphan\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set(1)
      task_list.up

      expect(task_list.task_at_cursor).to eq("L: w2")
    end

    it 'navigates from child to previous child' do
      io.tasks_content = "#3 Work\nL: w1\nL: w2\nL: w3\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set("0.3")
      task_list.up

      expect(task_list.task_at_cursor).to eq("L: w2")
    end

    it 'navigates from child to section header' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\n"
      task_list.cursor_set(0)
      task_list.section_toggle
      task_list.cursor_set("0.1")
      task_list.up

      expect(task_list.task_at_cursor).to include("Work")
    end
  end

  describe '#section_insert' do
    it 'does nothing when cursor is on a section header' do
      io.tasks_content = "#1 A\nL: a1\n#1 B\nL: b1\n"
      task_list.cursor_set(0)
      task_list.section_insert(1)

      expect(task_list.section_declared_count(0)).to eq(1)
    end

    it 'does nothing when target is not a section' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      task_list.cursor_set(0)
      task_list.section_insert(1)

      expect(task_list.count).to eq(2)
    end

    it 'moves a child from one section into another' do
      io.tasks_content = "#1 A\nL: a1\n#1 B\nL: b1\n"
      task_list.cursor_set("0.1")
      task_list.section_insert(1)

      expect(task_list.section_declared_count(0)).to eq(0)
      # After removing a1 from section A, section B is now at index 1
    end

    it 'moves task from below section into the section' do
      io.tasks_content = "#0 Work\nL: orphan\n"
      task_list.cursor_set(1)
      task_list.section_insert(0)

      expect(task_list.section_declared_count(0)).to eq(1)
      expect(task_list.count).to eq(1)
    end
  end

  describe '#find with sections' do
    it 'includes section children in find results' do
      io.tasks_content = "#1 Work\nL: important task\nL: other\n"
      results = task_list.find("important")

      expect(results.size).to eq(1)
      expect(results.first).to include("important")
    end
  end

  describe '#section_range' do
    it 'returns range for non-section item' do
      io.tasks_content = "L: task\n"
      expect(task_list.section_range(0)).to eq(0..0)
    end
  end

  describe '#cursor_on_section_header?' do
    it 'returns false on empty list' do
      io.tasks_content = ""
      expect(task_list.cursor_on_section_header?).to be false
    end
  end

  describe '#remove_task_at_cursor with section children' do
    it 'adjusts cursor when removing last child' do
      io.tasks_content = "#1 Work\nL: only child\n"
      task_list.cursor_set("0.1")
      task_list.remove_task_at_cursor

      expect(task_list.instance_variable_get(:@cursor)).to eq([0, nil])
    end

    it 'adjusts cursor when removing the last child by index' do
      io.tasks_content = "#2 Work\nL: first\nL: second\n"
      task_list.cursor_set("0.2")
      task_list.remove_task_at_cursor

      # cursor should clamp to the new last child
      expect(task_list.instance_variable_get(:@cursor)).to eq([0, 0])
      expect(task_list.task_at_cursor).to eq("L: first")
    end

    it 'adjusts cursor when removing middle child' do
      io.tasks_content = "#3 Work\nL: first\nL: second\nL: third\n"
      task_list.cursor_set("0.2")
      task_list.remove_task_at_cursor

      expect(task_list.section_declared_count(0)).to eq(2)
    end
  end

  describe '#save_all with sections' do
    it 'saves section header and children' do
      io.tasks_content = "#2 Work\nL: w1\nL: w2\nL: orphan\n"
      task_list.save_all

      expect(io.tasks_content).to eq("#2 Work\nL: w1\nL: w2\nL: orphan\n")
    end
  end

  describe '#zap_to_position empties a section' do
    it 'sets cursor to [top, nil] when zapping the only child out' do
      io.tasks_content = "#1 Work\nL: only\nL: orphan\n"
      task_list.cursor_set("0.1")
      task_list.zap_to_position(2)

      expect(task_list.instance_variable_get(:@cursor)).to eq([0, nil])
    end
  end

  describe '#iterative_find with sections' do
    it 'finds matches inside section children' do
      io.tasks_content = "#2 Work\nL: alpha\nL: beta\nL: gamma\n"
      task_list.iterative_find_init("beta")

      expect(task_list.task_at_cursor).to eq("L: beta")
    end

    it 'continues find across section children' do
      io.tasks_content = "#2 Work\nL: target one\nL: target two\nL: other\n"
      task_list.iterative_find_init("target")
      task_list.iterative_find_continue

      expect(task_list.task_at_cursor).to eq("L: target two")
    end
  end

  describe '#tag_tallies with sections' do
    it 'counts tags inside section children' do
      io.tasks_content = "#2 Work\nL: task 1\nR: task 2\nW: task 3\n"
      tallies = task_list.tag_tallies

      expect(tallies).to include(["L:", 1])
      expect(tallies).to include(["R:", 1])
    end
  end

  describe '#page_down with expanded sections' do
    it 'accounts for expanded section children in page size' do
      items = 35.times.map { |i| "L: task #{i}\n" }.join
      items += "#5 Big Section\n"
      items += 5.times.map { |i| "L: sec #{i}\n" }.join
      items += 5.times.map { |i| "L: after #{i}\n" }.join
      io.tasks_content = items

      # Expand the section so visible_count includes children
      task_list.cursor_set(35)
      task_list.section_toggle
      task_list.page_down

      labels = task_list.window.map { |label, _, _| label }
      # Page 2 starts partway through the expanded section
      expect(labels).to include("35.5")
    end
  end
end
