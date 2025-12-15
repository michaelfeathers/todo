require 'spec_helper'
require 'tasklist'
require 'fakeappio'

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

  describe '#todo_target_for' do
    context 'when calculating targets for the current month' do
      before do
        io.today_content = Day.new(DateTime.new(2023, 6, 15))
        io.archive_content = "2023-06-01 L: Task 1\n2023-06-05 L: Task 2\n2023-06-10 L: Task 3\n"
      end

      it 'calculates the required tasks per day to meet the monthly goal' do
        expect(io).to receive(:append_to_console).with("\n\n    Do 2 per day to meet monthly goal of 30\n\n    Daily average so far: 0.2\n\n")
        expect(io).to receive(:get_from_console)

        task_list.todo_target_for(30)
      end

      it 'handles the case where the goal has already been exceeded' do
        expect(io).to receive(:append_to_console).with("\n\n    Do 0 per day to meet monthly goal of 3\n\n    Daily average so far: 0.2\n\n")
        expect(io).to receive(:get_from_console)

        task_list.todo_target_for(3)
      end
    end

    context 'on the last day of the month' do
      before do
        io.today_content = Day.new(DateTime.new(2023, 6, 30))
        io.archive_content = "2023-06-01 L: Task 1\n2023-06-05 L: Task 2\n2023-06-10 L: Task 3\n"
      end

      it 'calculates the tasks needed for the final day' do
        expect(io).to receive(:append_to_console).with("\n\n    Do 7 per day to meet monthly goal of 10\n\n    Daily average so far: 0.1\n\n")
        expect(io).to receive(:get_from_console)

        task_list.todo_target_for(10)
      end
    end

    context 'with an empty archive' do
      before do
        io.today_content = Day.new(DateTime.new(2023, 6, 15))
        io.archive_content = ""
      end

      it 'calculates based on zero completed tasks' do
        expect(io).to receive(:append_to_console).with("\n\n    Do 2 per day to meet monthly goal of 30\n\n    Daily average so far: 0.0\n\n")
        expect(io).to receive(:get_from_console)

        task_list.todo_target_for(30)
      end
    end

    context 'with tasks from multiple months' do
      before do
        io.today_content = Day.new(DateTime.new(2023, 6, 15))
        io.archive_content = "2023-05-01 L: Task 1\n2023-06-05 L: Task 2\n2023-07-10 L: Task 3\n"
      end

      it 'only counts tasks from the current month' do
        expect(io).to receive(:append_to_console).with("\n\n    Do 2 per day to meet monthly goal of 30\n\n    Daily average so far: 0.1\n\n")
        expect(io).to receive(:get_from_console)

        task_list.todo_target_for(30)
      end
    end
  end

  describe '#todo_show_updates' do
    let(:io) { FakeAppIo.new }
    let(:task_list) { TaskList.new(io) }

    context 'when there are updates' do
      before do
        io.update_content = "2023-06-01 Update 1\n2023-06-02 Update 2\n"
      end

      it 'clears the console' do
        expect(io).to receive(:clear_console)
        task_list.todo_show_updates
      end

      it 'appends the updates to the console' do
        task_list.todo_show_updates
        expect(io.console_output_content).to eq("2023-06-01 Update 1\n2023-06-02 Update 2\n")
      end

      it 'returns to the prompt after displaying the updates' do
        expect(io).to receive(:get_from_console)
        task_list.todo_show_updates
      end
    end

    context 'when there are no updates' do
      before do
        io.update_content = ""
      end

      it 'clears the console' do
        expect(io).to receive(:clear_console)
        task_list.todo_show_updates
      end

      it 'does not append anything to the console' do
        task_list.todo_show_updates
        expect(io.console_output_content).to eq("")
      end

      it 'returns to the prompt' do
        expect(io).to receive(:get_from_console)
        task_list.todo_show_updates
      end
    end
   end

   describe '#todo_save' do
     context 'when there are tasks in the list' do
       before do
        io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"
        io.today_content = Day.new(DateTime.new(2023, 6, 1))
        task_list.cursor_set(1)
      end

      it 'appends the task at the cursor to the archive' do
        task_list.todo_save

        expect(io.archive_content).to eq("2023-06-01 L: task 2\n")
      end

      it 'removes the task at the cursor from the tasks' do
        task_list.todo_save

        expect(task_list.window).to eq([[0, " ", "L: task 1\n"], [1, "-", "L: task 3\n"]])
      end

      it 'updates the cursor position to the next task' do
        task_list.todo_save

        expect(task_list.window).to eq([[0, " ", "L: task 1\n"], [1, "-", "L: task 3\n"]])
      end

      it 'updates the cursor position to the previous task when at the last task' do
        task_list.cursor_set(2)
        task_list.todo_save

        expect(task_list.window).to eq([[0, " ", "L: task 1\n"], [1, "-", "L: task 2\n"]])
      end
    end

    context 'when the list is empty' do
      before do
        io.tasks_content = ""
      end

      it 'does not append anything to the archive' do
        task_list.todo_save

        expect(io.archive_content).to eq("")
      end

      it 'does not modify the tasks' do
        task_list.todo_save

        expect(io.tasks_content).to eq("")
      end
    end

    context 'when the task at the cursor is empty' do
      before do
        io.tasks_content = "L: task 1\n\nL: task 3\n"
        task_list.cursor_set(1)
      end

      it 'does not append anything to the archive' do
        task_list.todo_save

        expect(io.archive_content).to eq("")
      end

      it 'does not remove the empty task from the tasks' do
        task_list.todo_save

        expect(io.tasks_content).to eq("L: task 1\n\nL: task 3\n")
      end
    end
  end

    describe '#todo_save_no_remove' do
    context 'when there are tasks in the list' do
      before do
        io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"
        io.today_content = Day.new(DateTime.new(2023, 6, 1))
        task_list.cursor_set(1)
      end

      it 'appends the task at the cursor to the archive' do
        task_list.todo_save_no_remove

        expect(io.archive_content).to eq("2023-06-01 L: task 2\n")
      end

      it 'does not remove the task at the cursor from the tasks' do
        task_list.todo_save_no_remove

        expect(io.tasks_content).to eq("L: task 1\nL: task 2\nL: task 3\n")
      end

      it 'does not modify the cursor position' do
        task_list.todo_save_no_remove

        expect(task_list.window).to eq([[0, " ", "L: task 1\n"], [1, "-", "L: task 2\n"], [2, " ", "L: task 3\n"]])
      end
    end

    context 'when the list is empty' do
      before do
        io.tasks_content = ""
      end

      it 'does not append anything to the archive' do
        task_list.todo_save_no_remove

        expect(io.archive_content).to eq("")
      end

      it 'does not modify the tasks' do
        task_list.todo_save_no_remove

        expect(io.tasks_content).to eq("")
      end
    end

    context 'when the task at the cursor is empty' do
      before do
        io.tasks_content = "L: task 1\n\nL: task 3\n"
        task_list.cursor_set(1)
      end

      it 'does not append anything to the archive' do
        task_list.todo_save_no_remove

        expect(io.archive_content).to eq("")
      end

      it 'does not modify the tasks' do
        task_list.todo_save_no_remove

        expect(io.tasks_content).to eq("L: task 1\n\nL: task 3\n")
      end
    end
  end


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
      task_list.todo_grab_toggle

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

  it 'produces a summary for an empty archive' do
    io.today_content = Day.from_text("2020-01-01")
    MonthsReport.new(io, nil, TEST_COLUMNS).run
    # task_list.todo_month_summaries TEST_COLUMNS

    expect(io.console_output_content).to eq(empty_archive_expected)
  end

  it 'shows archive entries of today' do
    io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
    io.today_content = Day.from_text("2020-01-12")
    task_list.todo_today 0
    expect(io.console_output_content).to eq("\n2020-01-12 R: Thing Y\n\n1\n\n")
  end

  it 'shows trend' do
    io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n2020-01-12 L: Another thing\n"
    task_list.todo_trend
    expect(io.console_output_content).to eq("  1  2020-01-11\n  2  2020-01-12\n\n")
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
    task_list.todo_page_down
    task_list.add("L: new task")

    expect(task_list.window[0]).to eq([0, "-", "L: new task\n"])
  end

  it 'does not write to archive when saving an empty todo list' do
    io.tasks_content = ""
    task_list.todo_save

    expect(task_list.window).to eq([])
  end

  it 'does not write to archive when save_no_remove on an empty todo list' do
    io.tasks_content = ""
    task_list.todo_save_no_remove

    expect(task_list.window).to eq([])
  end

  it 'pushes task at cursor to next day' do
    io.tasks_content = "L: task A\n"
    io.update_content = ""
    io.today_content = Day.from_text("2022-12-21")
    task_list.todo_push "1"

    expect(io.update_content.first).to eq("2022-12-22 L: task A\n")
    expect(task_list.window).to eq([])
  end

  it 'noops push on no tasks' do
    io.update_content = []
    io.today_content = Day.from_text("2022-12-21")
    task_list.todo_push "1"

    expect(io.update_content).to eq([])
    expect(task_list.window).to eq([])
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

end

