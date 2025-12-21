require 'spec_helper'
require 'tasklist'
require 'fakeappio'
require 'gruff'

require 'commands/add'
require 'commands/Help'


empty_archive_expected = "

             Win        R7K       Life      Total   Adjusted

Jan            0          0          0          0          0
Feb            0          0          0          0          0
Mar            0          0          0          0          0
Apr            0          0          0          0          0
May            0          0          0          0          0
Jun            0          0          0          0          0
Jul            0          0          0          0          0
Aug            0          0          0          0          0
Sep            0          0          0          0          0
Oct            0          0          0          0          0
Nov            0          0          0          0          0
Dec            0          0          0          0          0

               0          0          0          0          0



"

TEST_COLUMNS = [["Win",   ->(tasks) { tasks.W.count } ],
                ["R7K",   ->(tasks) { tasks.R.count } ],
                ["Life",  ->(tasks) { tasks.L.count } ],
                ["Total", ->(tasks) { tasks.count } ],
                ["Adjusted", ->(tasks) { tasks.adjusted_count } ]]


class TestingHelp < Help
  attr_accessor :descs

  def command_descs
    @descs
  end
end

describe TaskList do
  let(:io) { FakeAppIo.new }
  let(:task_list) { TaskList.new(io) }

  describe '#up' do
    it 'moves the cursor up by one position' do
      # io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"
      task_list.add("L: T 3");
      task_list.add("L: T 2");
      task_list.add("L: T 1");

      task_list.cursor_set(2)

      task_list.up

      expect(task_list.window).to eq([[0, " ", "L: T 1\n"],
                                      [1, "-", "L: T 2\n"],
                                      [2, " ", "L: T 3\n"]])

    end

    it 'does not move the cursor if it is already at the first task' do
      io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"
      task_list.cursor_set(0)

      task_list.up

      expect(task_list.window).to eq([[0, "-", "L: task 1\n"], [1, " ", "L: task 2\n"], [2, " ", "L: task 3\n"]])
    end

    it 'moves the task above the cursor down when in grab mode' do
      io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"

      task_list.cursor_set(1)
      task_list.grab_toggle

      task_list.up

      expect(task_list.window[0]).to eq([0, "*",  "L: task 2\n"])
      expect(task_list.window[1]).to eq([1, " ",  "L: task 1\n"])
    end

    it 'does not move the task above the cursor down when not in grab mode' do
      io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"

      task_list.cursor_set(1)

      task_list.up

      expect(task_list.window[0]).to eq([0, "-",  "L: task 1\n"])
      expect(task_list.window[1]).to eq([1, " ",  "L: task 2\n"])
    end
  end

  it 'returns task at cursor when not empty' do
    io.tasks_content = "L: task AA\nL: task BB\n"
    expect(task_list.task_at_cursor).to eq("L: task AA")
  end

  it 'returns empty string for task at cursor when empty' do
    expect(task_list.task_at_cursor).to eq("")
  end

  it 'finds simple text' do
    io.tasks_content = "L: task AA\nL: task BB\n"
    expect(task_list.find("AA")).to eq([" 0 L: task AA\n"])
  end

  it 'ignores case when it finds' do
    io.tasks_content = "L: task A\nL: task B\n"
    expect(task_list.find("b")).to eq([" 1 L: task B\n"])
  end

  describe '#save_all' do
    it 'saves all tasks to the IO' do
      io.tasks_content = "L: task 1\nL: task 2\n"
      task_list.save_all
      expect(io.tasks_content).to eq("L: task 1\nL: task 2\n")
    end

    it 'saves an empty task list' do
      io.tasks_content = ""
      task_list.save_all
      expect(io.tasks_content).to eq("")
    end
  end

  it 'produces a summary for an empty archive' do
    io.today_content = Day.from_text("2020-01-01")
    MonthsReport.new(io, nil, TEST_COLUMNS).run
    # task_list.todo_month_summaries TEST_COLUMNS

    expect(io.console_output_content).to eq(empty_archive_expected)
  end

  it 'adds a task on an empty todo list' do
    io.tasks_content = ""
    task_list.add("this is a test")
    expect(task_list.window).to eq([[0, "-", "this is a test\n"]])
  end

  it 'adds a task on an non-empty todo list' do
    io.tasks_content = "L: task A\n"
    task_list.add("L: this is a test")

    expect(task_list.window).to eq([[0, "-", "L: this is a test\n"],[1, " ", "L: task A\n"]])
  end

  it 'moves the cursor on an add' do
    io.tasks_content = 50.times.map { "L: task\n" }.join
    task_list.page_down
    task_list.add("L: new task")

    expect(task_list.window[0]).to eq([0, "-", "L: new task\n"])
  end

  it 'preserves a tag on editing' do
    io.tasks_content = "L: task\n"
    task_list.edit "edited task"

    expect(task_list.window).to eq([[0, "-", "L: edited task\n"]])
  end

  it 'can return 1 tag tally' do
    io.tasks_content = "L: task\n"
    expect(task_list.tag_tallies).to eq ([["L:", 1]])
  end

  it 'can return 2 tag tallies' do
    io.tasks_content = "L: task\nR: task\nR: task\n"
    expect(task_list.tag_tallies).to eq ([["L:",1],["R:", 2]])
  end

  it 'can return 2 tag tallies' do
    io.tasks_content = "L: task\nR: task\nutaski\nR: task\nutask\n"
    expect(task_list.untagged_tally).to eq (2)
  end

  describe 'empty list edge cases' do
    let(:empty_io) { FakeAppIo.new }
    let(:empty_list) { TaskList.new(empty_io) }

    before do
      empty_io.tasks_content = ""
      empty_io.today_content = Day.today
    end

    describe '#cursor_set' do
      it 'does not crash when setting cursor on empty list' do
        expect { empty_list.cursor_set(0) }.not_to raise_error
        expect { empty_list.cursor_set(5) }.not_to raise_error
        expect { empty_list.cursor_set(-1) }.not_to raise_error
      end

      it 'keeps cursor at 0 when list is empty' do
        empty_list.cursor_set(10)
        expect(empty_list.instance_variable_get(:@cursor)).to eq(0)
      end
    end

    describe '#zap_to_position' do
      it 'does not crash when zapping on empty list' do
        expect { empty_list.zap_to_position(0) }.not_to raise_error
        expect { empty_list.zap_to_position(5) }.not_to raise_error
      end

      it 'keeps list empty after zap attempt' do
        empty_list.zap_to_position(10)
        expect(empty_list.empty?).to be true
      end
    end

    describe '#iterative_find_continue' do
      it 'does not crash when continuing find on empty list' do
        empty_list.instance_variable_set(:@last_search_text, "test")
        expect { empty_list.iterative_find_continue }.not_to raise_error
      end

      it 'handles empty list gracefully when search text exists' do
        empty_list.instance_variable_set(:@last_search_text, "find me")
        empty_list.iterative_find_continue
        expect(empty_list.instance_variable_get(:@cursor)).to eq(0)
      end
    end

    describe '#remove_task_at_cursor' do
      it 'does not crash when removing from empty list' do
        expect { empty_list.remove_task_at_cursor }.not_to raise_error
      end

      it 'keeps cursor at 0 after removing from empty list' do
        empty_list.remove_task_at_cursor
        expect(empty_list.instance_variable_get(:@cursor)).to eq(0)
      end

      it 'maintains valid cursor state after removing last task' do
        empty_io.tasks_content = "Single task\n"
        list_with_one = TaskList.new(empty_io)

        list_with_one.remove_task_at_cursor

        expect(list_with_one.empty?).to be true
        expect(list_with_one.instance_variable_get(:@cursor)).to eq(0)
      end
    end

    describe '#task_at_cursor' do
      it 'returns empty string for empty list' do
        expect(empty_list.task_at_cursor).to eq("")
      end
    end

    describe '#down' do
      it 'does not crash on empty list' do
        expect { empty_list.down }.not_to raise_error
      end

      it 'cursor stays at 0 on empty list' do
        empty_list.down
        expect(empty_list.instance_variable_get(:@cursor)).to eq(0)
      end
    end

    describe '#up' do
      it 'does not crash on empty list' do
        expect { empty_list.up }.not_to raise_error
      end

      it 'cursor stays at 0 on empty list' do
        empty_list.up
        expect(empty_list.instance_variable_get(:@cursor)).to eq(0)
      end
    end

    describe '#edit' do
      it 'does not crash on empty list' do
        expect { empty_list.edit("new text") }.not_to raise_error
      end
    end

    describe '#edit_replace' do
      it 'does not crash on empty list' do
        expect { empty_list.edit_replace(0, ["new", "text"]) }.not_to raise_error
      end
    end

    describe '#edit_insert' do
      it 'does not crash on empty list' do
        expect { empty_list.edit_insert(1, ["new", "text"]) }.not_to raise_error
      end
    end

    describe '#retag' do
      it 'does not crash on empty list' do
        expect { empty_list.retag("W") }.not_to raise_error
      end
    end

    describe '#insert_blank' do
      it 'can insert blank line into empty list' do
        empty_list.insert_blank
        expect(empty_list.count).to eq(1)
      end
    end

    describe '#iterative_find_init' do
      it 'does not crash on empty list' do
        expect { empty_list.iterative_find_init("test") }.not_to raise_error
      end

      it 'does not find anything on empty list' do
        empty_list.iterative_find_init("test")
        expect(empty_list.instance_variable_get(:@cursor)).to eq(0)
      end
    end

    describe '#window' do
      it 'returns empty array for empty list' do
        expect(empty_list.window).to eq([])
      end
    end

    describe '#find' do
      it 'returns empty array for empty list' do
        expect(empty_list.find("test")).to eq([])
      end
    end

    describe '#zap_to_top' do
      it 'does not crash on empty list' do
        expect { empty_list.zap_to_top }.not_to raise_error
      end
    end
  end

end

