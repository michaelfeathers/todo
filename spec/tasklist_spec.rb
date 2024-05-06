$:.unshift File.dirname(__FILE__)

require 'tasklist'
require 'fakeappio'

empty_archive_with_percent_expected = "

             R7K       Life      Total      R7K %

Jan            0          0          0          0
Feb            0          0          0          0
Mar            0          0          0          0
Apr            0          0          0          0
May            0          0          0          0
Jun            0          0          0          0
Jul            0          0          0          0
Aug            0          0          0          0
Sep            0          0          0          0
Oct            0          0          0          0
Nov            0          0          0          0
Dec            0          0          0          0

               0          0          0          0



"

empty_archive_expected = "

             R7K       Life      Total

Jan            0          0          0
Feb            0          0          0
Mar            0          0          0
Apr            0          0          0
May            0          0          0
Jun            0          0          0
Jul            0          0          0
Aug            0          0          0
Sep            0          0          0
Oct            0          0          0
Nov            0          0          0
Dec            0          0          0

               0          0          0



"




describe TaskList do

  let(:io) { FakeAppIo.new }
  let(:task_list) { TaskList.new(io) }

  it 'finds simple text' do
    io.actions_content = "L: task AA\nL: task BB\n"
    expect(task_list.find("AA")).to eq([" 0 L: task AA\n"])
  end

  it 'ignores case when it finds' do
    io.actions_content = "L: task A\nL: task B\n" 
    expect(task_list.find("b")).to eq([" 1 L: task B\n"])
  end

  it 'produces a summary for an empty archive' do
    io.today_content = Day.from_text("2020-01-01")
    task_list.todo_month_summaries
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
    io.actions_content = ""
    task_list.todo_add("this is a test")
    task_list.render
    expect(io.console_output_content).to eq("\n\n 0 - this is a test\n\n")
  end

  it 'adds a task on an non-empty todo list' do
    io.actions_content = "L: task A\n"
    task_list.todo_add("L: this is a test")
    task_list.render
    expect(io.console_output_content).to eq("\n\n 0 - L: this is a test\n 1   L: task A\n\n")
  end

  it 'moves the cursor on an add' do
    io.actions_content = 50.times.map { "L: task\n" }.join
    task_list.todo_page_down
    task_list.todo_add("L: new task")
    task_list.render
    expect(io.console_output_content[0..18]).to eq("\n\n 0 - L: new task\n")
  end

  it 'does not write to archive when saving an empty todo list' do
    io.actions_content = ""
    task_list.todo_save
    task_list.render
    expect(io.archive_content).to eq("")
  end

  it 'does not write to archive when save_no_remove on an empty todo list' do
    io.actions_content = ""
    task_list.todo_save_no_remove
    task_list.render
    expect(io.archive_content).to eq("")
  end

  it 'pushes task at cursor to next day' do
    io.actions_content = "L: task A\n"
    io.update_content = ""
    io.today_content = Day.from_text("2022-12-21")
    task_list.todo_push "1"
    task_list.render
    expect(io.update_content.first).to eq("2022-12-22 L: task A\n")
    expect(io.console_output_content).to eq("\n\n\n")
  end
  
  it 'noops push on no tasks' do
    io.update_content = []
    io.today_content = Day.from_text("2022-12-21")
    task_list.todo_push "1"
    task_list.render
    expect(io.update_content).to eq([])
    expect(io.console_output_content).to eq("\n\n\n")
  end

  it 'edits a task with no tag' do
    io.actions_content = "task\n"
    task_list.todo_edit ["edited", "task"]
    task_list.render
    expect(io.console_output_content).to eq("\n\n 0 - edited task\n\n")
  end

  it 'preserves a tag on editing' do
    io.actions_content = "L: task\n"
    task_list.todo_edit ["edited", "task"]
    task_list.render
    expect(io.console_output_content).to eq("\n\n 0 - L: edited task\n\n")
  end

  it 'can return 1 tag tally' do
    io.actions_content = "L: task\n"
    expect(task_list.tag_tallies).to eq ([["L:", 1]])
  end

  it 'can return 2 tag tallies' do
    io.actions_content = "L: task\nR: task\nR: task\n"
    expect(task_list.tag_tallies).to eq ([["L:",1],["R:", 2]])
  end

  it 'can return 2 tag tallies' do
    io.actions_content = "L: task\nR: task\nutaski\nR: task\nutask\n"
    expect(task_list.untagged_tally).to eq (2)
  end

end
