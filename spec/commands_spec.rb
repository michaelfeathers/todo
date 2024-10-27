require 'spec_helper'
require 'session'
require 'commands'
require 'fakeappio'
require 'testrenderer'

RENDER_PAD = "\n\n"


describe ToDoMoveToRandomPositionOnOtherList do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) {rendering_of(session) }

  describe '#run' do
    it 'moves the task at the cursor from the foreground list to a random position on the background list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"
      session.list.cursor_set(1)

      expect_any_instance_of(Session).to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'moves the task at the cursor from the background list to a random position on the foreground list' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = "Task A\nTask B\nTask C\n"
      session.switch_lists
      session.list.cursor_set(1)

      expect_any_instance_of(Session).to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'does not modify the lists if the foreground list is empty' do
      f_io.tasks_content = ""
      b_io.tasks_content = "Task A\nTask B\nTask C\n"

      expect_any_instance_of(Session).not_to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'does not modify the lists if the background list is empty' do
      f_io.tasks_content = "Task 1\nTask 2\nTask 3\n"
      b_io.tasks_content = ""
      session.switch_lists

      expect_any_instance_of(Session).not_to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end
  end

  describe '#matches?' do
    it 'matches a command with "_"' do
      expect(ToDoMoveToRandomPositionOnOtherList.new.matches?('_')).to be_truthy
    end

    it 'does not match a command other than "_"' do
      expect(ToDoMoveToRandomPositionOnOtherList.new.matches?('x')).to be_falsey
    end
  end
end


describe ToDoTagTallies do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'displays tag tallies and untagged count' do
      f_io.tasks_content = "L: task 1\nR: task 2\nR: task 3\nW: task 4\nL: task 5\ntask 6\ntask 7\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          2")
      expect(f_io.console_output_content).to include("   R:          2")
      expect(f_io.console_output_content).to include("   W:          1")
      expect(f_io.console_output_content).to include("   Untagged    2")
    end

    it 'returns to the prompt after displaying tag tallies' do
      f_io.tasks_content = "L: task 1\nR: task 2\nR: task 3\nW: task 4\nL: task 5\ntask 6\ntask 7\n"

      expect(f_io).to receive(:get_from_console)

      ToDoTagTallies.new.run('tt', session)
    end

    it 'displays only untagged count when no tags are present' do
      f_io.tasks_content = "task 1\ntask 2\ntask 3\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).not_to include("L:")
      expect(f_io.console_output_content).not_to include("R:")
      expect(f_io.console_output_content).not_to include("W:")
      expect(f_io.console_output_content).to include("   Untagged    3")
    end

    it 'displays tag tallies correctly when only one tag is present' do
      f_io.tasks_content = "L: task 1\nL: task 2\nL: task 3\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          3")
      expect(f_io.console_output_content).to include("   Untagged    0")
    end

    it 'does not count empty lines as untagged tasks' do
      f_io.tasks_content = "L: task 1\n\nR: task 2\n\n\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          1")
      expect(f_io.console_output_content).to include("   R:          1")
      expect(f_io.console_output_content).to include("   Untagged    0")
    end
  end

  describe '#matches?' do
    it 'matches a command with "tt"' do
      expect(ToDoTagTallies.new.matches?('tt')).to be_truthy
    end

    it 'does not match a command other than "tt"' do
      expect(ToDoTagTallies.new.matches?('xx')).to be_falsey
    end
  end
end

describe ToDoRemove do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'removes an task' do
    f_io.tasks_content = "L: task AA\nL: task BB\n"
    f_io.console_input_content = "Y"
    ToDoRemove.new.run("r", session)
    expect(f_io.tasks_content).to eq("L: task BB\n")
  end
end


def cursor_char index
  return "-" if index == 0
  " "
end

describe ToDoPageDown do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'shows the first page of tasks' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.tasks_content = tasks.join
    session.render_naked
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'shows the second page of tasks' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.tasks_content = tasks.join
    ToDoPageDown.new.run("dd", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'is noop when on the last page' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.tasks_content = tasks.join
    ToDoPageDown.new.run("dd", session)
    ToDoPageDown.new.run("dd", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end
end

describe ToDoPageUp do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }


  it 'shows the first page of tasks' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.tasks_content = tasks.join
    ToDoPageUp.new.run("uu", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'shows the first page of tasks after previously paging down' do
    tasks =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.tasks_content = tasks.join
    ToDoPageDown.new.run("dd", session)
    ToDoPageUp.new.run("uu", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end

end

describe ToDoPrintArchive do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'prints the contents of the archive' do
    archive_content = "2023-06-07 L: Task 1\n2023-06-08 R: Task 2\n"
    f_io.archive_content = archive_content

    ToDoPrintArchive.new.run("pa", session)

    expect(f_io.console_output_content).to eq(archive_content)
  end

  it 'prints an empty archive when there are no saved tasks' do
    f_io.archive_content = ""

    ToDoPrintArchive.new.run("pa", session)

    expect(f_io.console_output_content).to eq("")
  end

end


describe ToDoZapToPosition do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'zaps the item at zero to one' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output = RENDER_PAD + [" 0 - L: second\n", " 1   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 1", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)

  end

  it 'saturates when asked to zap outside the range high' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output = RENDER_PAD + [" 0 - L: second\n", " 1   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 2", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)

  end

  it 'saturates when asked to zap outside the range low' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output =  RENDER_PAD + [" 0   L: second\n", " 1 - L: first\n\n"].join
    CursorSet.new.run("c 1", session)
    ToDoZapToPosition.new.run("z -1", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)

  end

  it 'noops when asked to zap to the same position' do
    f_io.tasks_content = [ "L: first\n", "L: second\n"].join
    output =  RENDER_PAD + [" 0 - L: first\n", " 1   L: second\n\n"].join
    ToDoZapToPosition.new.run("z 0", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)
  end

  it 'has insertion rather than swap aemantics' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output =  RENDER_PAD + [" 0 - L: second\n", " 1   L: third\n 2   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 2", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)
  end

end

describe ToDoReTag do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'retags an L to an R' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output =  RENDER_PAD + [ " 0   L: first\n", " 1 - R: second\n",  " 2   L: third\n\n"].join
    CursorSet.new.run("c 1", session)
    ToDoReTag.new.run("rt r", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)
  end

  it'does nothing when regtagging in an empty task list' do
    f_io.tasks_content = ""
    output =  RENDER_PAD + "\n"
    ToDoReTag.new.run("rt r", session)
    session.render_naked
    expect(f_io.console_output_content).to eq(output)
   end

   it'adds a tag to a task with no tag' do
     f_io.tasks_content = ["first\n"].join
     output =  RENDER_PAD + " 0 - L: first\n\n"
     ToDoReTag.new.run("rt l", session)
     session.render_naked
     expect(f_io.console_output_content).to eq(output)
   end

   it'does nothing when no new tag is supplied' do
     f_io.tasks_content = ["R: first\n"].join
     output =  RENDER_PAD + " 0 - R: first\n\n"
     ToDoReTag.new.run("rt", session)
     session.render_naked
     expect(f_io.console_output_content).to eq(output)
   end

 end


describe ToDoToday do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

   it'shows the tasks for the current day' do
     f_io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
     f_io.today_content = Day.from_text("2020-01-12")
     ToDoToday.new.run("t", session)
     expect(f_io.console_output_content).to eq("\n2020-01-12 R: Thing Y\n\n1\n\n")
   end


   it'shows the tasks for the previous day' do
     f_io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
     f_io.today_content = Day.from_text("2020-01-12")
     ToDoToday.new.run("t 1", session)
     expect(f_io.console_output_content).to eq("\n2020-01-11 R: Thing X\n\n1\n\n")
   end

end


describe ToDoSwitchLists do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'switches away foreground' do
     f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     output = RENDER_PAD + " 0 - L: first\n 1   L: second\n 2   L: third\n\n"
     session.render_naked
     expect(session.list.io.console_output_content).to eq(output)

     ToDoSwitchLists.new.run("w", session)
     session.render_naked
     expect(session.list.io.console_output_content).to eq("BACKGROUND" + RENDER_PAD + "\n")
  end

  it 'switches foreground and background' do
     f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     b_io.tasks_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
     output_before = RENDER_PAD + [" 0 - L: first\n", " 1   L: second\n",  " 2   L: third\n\n"].join
     output_after  = "BACKGROUND" + RENDER_PAD + [" 0 - R: first\n 1   R: second\n 2   R: third\n\n"].join

     session.render_naked
     expect(session.list.io.console_output_content).to eq(output_before)

     ToDoSwitchLists.new.run("w", session)
     session.render_naked
     expect(session.list.io.console_output_content).to eq(output_after)
  end

  it 'switches to the background list and moves the cursor to the specified position' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    b_io.tasks_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
    output_after  = "BACKGROUND" + RENDER_PAD + [" 0   R: first\n", " 1 - R: second\n", " 2   R: third\n\n"].join

    ToDoSwitchLists.new.run("w 1", session)
    session.render_naked
    expect(session.list.io.console_output_content).to eq(output_after)
  end

  it 'does not change the cursor position if no position is specified' do
    f_io.tasks_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    b_io.tasks_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
    output_after  = "BACKGROUND" + RENDER_PAD + [" 0 - R: first\n", " 1   R: second\n", " 2   R: third\n\n"].join

    ToDoSwitchLists.new.run("w", session)
    session.render_naked
    expect(session.list.io.console_output_content).to eq(output_after)
  end

end


describe ToDoZapToTop do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'moves the task at the cursor to position 0' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n",
      "L: task 3\n",
      "L: task 4\n"
    ]
    output = [
      " 0   L: task 2\n",
      " 1   L: task 0\n",
      " 2 - L: task 1\n",
      " 3   L: task 3\n",
      " 4   L: task 4\n"
    ].join

    f_io.tasks_content = tasks.join
    session.list.cursor_set(2)
    ToDoZapToTop.new.run("zz", session)
    session.render_naked

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'does nothing when the cursor is already at position 0' do
    tasks = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n",
      "L: task 3\n",
      "L: task 4\n"
    ]
    output = [
      " 0 - L: task 0\n",
      " 1   L: task 1\n",
      " 2   L: task 2\n",
      " 3   L: task 3\n",
      " 4   L: task 4\n"
    ].join

    f_io.tasks_content = tasks.join
    session.list.cursor_set(0)
    ToDoZapToTop.new.run("zz", session)
    session.render_naked

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

end

describe ToDoSaveActions do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'saves the tasks without quitting' do
    tasks_content = "L: task 1\nL: task 2\n"
    f_io.tasks_content = tasks_content

    ToDoSaveActions.new.run("@", session)

    expect(f_io.tasks_content).to eq(tasks_content)
  end
end
