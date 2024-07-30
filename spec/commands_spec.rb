require 'spec_helper'
require 'session'
require 'commands'
require 'fakeappio'

RENDER_PAD = "\n\n"


describe ToDoMoveTaskToOther do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'moves the task at the cursor from the foreground list to the background list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      session.list.cursor_set(1)

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("Task 1\nTask 3\n")
      expect(b_io.actions_content).to eq("Task 2\n")
    end

    it 'moves the task at the cursor from the background list to the foreground list' do
      b_io.actions_content = "Task A\nTask B\nTask C\n"
      session.switch_lists
      session.list.cursor_set(1)

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("Task B\n")
      expect(b_io.actions_content).to eq("Task A\nTask C\n")
    end

    it 'does not modify the lists if the foreground list is empty' do
      f_io.actions_content = ""
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("")
      expect(b_io.actions_content).to eq("\nTask A\nTask B\nTask C\n")
    end

    it 'does not modify the lists if the background list is empty' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = ""
      session.switch_lists

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("\nTask 1\nTask 2\nTask 3\n")
      expect(b_io.actions_content).to eq("")
    end
  end

  describe '#matches?' do
    it 'matches a command with "-"' do
      expect(ToDoMoveTaskToOther.new.matches?('-')).to be_truthy
    end

    it 'does not match a command other than "-"' do
      expect(ToDoMoveTaskToOther.new.matches?('x')).to be_falsey
    end
  end
end

describe ToDoMoveToRandomPositionOnOtherList do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'moves the task at the cursor from the foreground list to a random position on the background list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task A\nTask B\nTask C\n"
      session.list.cursor_set(1)

      expect_any_instance_of(Session).to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'moves the task at the cursor from the background list to a random position on the foreground list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task A\nTask B\nTask C\n"
      session.switch_lists
      session.list.cursor_set(1)

      expect_any_instance_of(Session).to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'does not modify the lists if the foreground list is empty' do
      f_io.actions_content = ""
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      expect_any_instance_of(Session).not_to receive(:move_task_to_random_position_on_other_list)

      ToDoMoveToRandomPositionOnOtherList.new.run('_', session)
    end

    it 'does not modify the lists if the background list is empty' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = ""
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
      f_io.actions_content = "L: task 1\nR: task 2\nR: task 3\nW: task 4\nL: task 5\ntask 6\ntask 7\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          2")
      expect(f_io.console_output_content).to include("   R:          2")
      expect(f_io.console_output_content).to include("   W:          1")
      expect(f_io.console_output_content).to include("   Untagged    2")
    end

    it 'returns to the prompt after displaying tag tallies' do
      f_io.actions_content = "L: task 1\nR: task 2\nR: task 3\nW: task 4\nL: task 5\ntask 6\ntask 7\n"

      expect(f_io).to receive(:get_from_console)

      ToDoTagTallies.new.run('tt', session)
    end

    it 'displays only untagged count when no tags are present' do
      f_io.actions_content = "task 1\ntask 2\ntask 3\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).not_to include("L:")
      expect(f_io.console_output_content).not_to include("R:")
      expect(f_io.console_output_content).not_to include("W:")
      expect(f_io.console_output_content).to include("   Untagged    3")
    end

    it 'displays tag tallies correctly when only one tag is present' do
      f_io.actions_content = "L: task 1\nL: task 2\nL: task 3\n"

      ToDoTagTallies.new.run('tt', session)

      expect(f_io.console_output_content).to include("   L:          3")
      expect(f_io.console_output_content).to include("   Untagged    0")
    end

    it 'does not count empty lines as untagged tasks' do
      f_io.actions_content = "L: task 1\n\nR: task 2\n\n\n"

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

describe ToDoFind do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'finds tasks containing the specified text in the current list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"

      ToDoFind.new.run('f 2', session)

      expect(f_io.console_output_content).to include("Task 2")
    end

    it 'finds tasks case-insensitively' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"

      ToDoFind.new.run('f task', session)

      expect(f_io.console_output_content).to include("Task 1")
      expect(f_io.console_output_content).to include("Task 2")
      expect(f_io.console_output_content).to include("Task 3")
    end

    it 'limits the search results to the specified count' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"

      ToDoFind.new.run('f Task 2', session)

      expect(f_io.console_output_content.scan("Task").count).to eq(2)
    end

    it 'does not find tasks if the specified text is not present' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"

      ToDoFind.new.run('f X', session)

      expect(f_io.console_output_content).not_to include("Task")
    end

    it 'returns to the prompt after displaying the search results' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"

      expect(f_io).to receive(:get_from_console)

      ToDoFind.new.run('f 2', session)
    end
  end

  describe '#matches?' do
    it 'matches a command with "f" followed by text' do
      expect(ToDoFind.new.matches?('f text')).to be_truthy
    end

    it 'matches a command with "f" followed by text and a number' do
      expect(ToDoFind.new.matches?('f text 5')).to be_truthy
    end

    it 'does not match a command without "f"' do
      expect(ToDoFind.new.matches?('text')).to be_falsey
    end

    it 'does not match a command with "f" but no text' do
      expect(ToDoFind.new.matches?('f')).to be_falsey
    end

  end
end

describe ToDoGlobalFind do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  describe '#run' do
    it 'finds tasks containing the specified text in the foreground list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      ToDoGlobalFind.new.run('gf 2', session)

      expect(f_io.console_output_content).to include("Task 2")
    end

    it 'finds tasks containing the specified text in the background list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      ToDoGlobalFind.new.run('gf B', session)

      expect(f_io.console_output_content).to include("Background:")
      expect(f_io.console_output_content).to include("Task B")
    end

    it 'finds tasks containing the specified text in both lists' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task 2\nTask B\nTask C\n"

      ToDoGlobalFind.new.run('gf 2', session)

      expect(f_io.console_output_content).to include("Task 2")
      expect(f_io.console_output_content).to include("Background:")
      expect(f_io.console_output_content).to include("Task 2")
    end

    it 'does not find tasks if the specified text is not present in either list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      ToDoGlobalFind.new.run('gf X', session)

      expect(f_io.console_output_content).not_to include("Task")
    end

    it 'returns to the prompt after displaying the search results' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      expect(f_io).to receive(:get_from_console)

      ToDoGlobalFind.new.run('gf 2', session)
    end
  end

  describe '#matches?' do
    it 'matches a command with "gf" followed by text' do
      expect(ToDoGlobalFind.new.matches?('gf text')).to be_truthy
    end

    it 'does not match a command without "gf"' do
      expect(ToDoGlobalFind.new.matches?('text')).to be_falsey
    end

    it 'does not match a command with "gf" but no text' do
      expect(ToDoGlobalFind.new.matches?('gf')).to be_falsey
    end
  end
end

describe ToDoRemove do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'removes an action' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    f_io.console_input_content = "Y"
    ToDoRemove.new.run("r", session)
    expect(f_io.actions_content).to eq("L: task BB\n")
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
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'shows the second page of tasks' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join
    ToDoPageDown.new.run("dd", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'is noop when on the last page' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join
    ToDoPageDown.new.run("dd", session)
    ToDoPageDown.new.run("dd", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end
end

describe ToDoIterativeFind do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'finds the token and moves the cursor to the line where it is first found' do
    actions = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2 with token\n",
      "L: task 3 with token\n",
      "L: task 4\n"
    ]
    output = actions.map.with_index do |action, i|
      cursor = i == 2 ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]
    end.join

    f_io.actions_content = actions.join
    session.list.cursor_set(1)
    ToDoIterativeFind.new.run("ff token", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'does not change the cursor position if the token is not found' do
    actions = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n",
      "L: task 3\n",
      "L: task 4\n"
    ]
    output = actions.map.with_index do |action, i|
      cursor = i == 1 ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]
    end.join

    f_io.actions_content = actions.join
    session.list.cursor_set(1)
    ToDoIterativeFind.new.run("ff token", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'finds the token from the next line after the cursor when no text is provided' do
    actions = [
      "L: task 0\n",
      "L: task 1 with token\n",
      "L: task 2\n",
      "L: task 3 with token\n",
      "L: task 4\n"
    ]
    output = actions.map.with_index do |action, i|
      cursor = i == 3 ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]
    end.join

    f_io.actions_content = actions.join
    session.list.cursor_set(1)
    ToDoIterativeFind.new.run("ff token", session)
    ToDoIterativeFind.new.run("ff", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

end


describe ToDoPageUp do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }


  it 'shows the first page of tasks' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join
    ToDoPageUp.new.run("uu", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'shows the first page of tasks after previously paging down' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join
    ToDoPageDown.new.run("dd", session)
    ToDoPageUp.new.run("uu", session)
    session.list.render
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
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output = RENDER_PAD + [" 0 - L: second\n", " 1   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 1", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)

  end

  it 'saturates when asked to zap outside the range high' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output = RENDER_PAD + [" 0 - L: second\n", " 1   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 2", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)

  end

  it 'saturates when asked to zap outside the range low' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output =  RENDER_PAD + [" 0   L: second\n", " 1 - L: first\n\n"].join
    CursorSet.new.run("c 1", session)
    ToDoZapToPosition.new.run("z -1", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)

  end

  it 'noops when asked to zap to the same position' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output =  RENDER_PAD + [" 0 - L: first\n", " 1   L: second\n\n"].join
    ToDoZapToPosition.new.run("z 0", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
  end

  it 'has insertion rather than swap aemantics' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output =  RENDER_PAD + [" 0 - L: second\n", " 1   L: third\n 2   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 2", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
  end

end

describe ToDoReTag do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'retags an L to an R' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output =  RENDER_PAD + [ " 0   L: first\n", " 1 - R: second\n",  " 2   L: third\n\n"].join
    CursorSet.new.run("c 1", session)
    ToDoReTag.new.run("rt r", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
  end

  it'does nothing when regtagging in an empty task list' do
    f_io.actions_content = ""
    output =  RENDER_PAD + "\n"
    ToDoReTag.new.run("rt r", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
   end

   it'adds a tag to a task with no tag' do
     f_io.actions_content = ["first\n"].join
     output =  RENDER_PAD + " 0 - L: first\n\n"
     ToDoReTag.new.run("rt l", session)
     session.list.render
     expect(f_io.console_output_content).to eq(output)
   end

   it'does nothing when no new tag is supplied' do
     f_io.actions_content = ["R: first\n"].join
     output =  RENDER_PAD + " 0 - R: first\n\n"
     ToDoReTag.new.run("rt", session)
     session.list.render
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
     f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     output = RENDER_PAD + " 0 - L: first\n 1   L: second\n 2   L: third\n\n"
     session.list.render
     expect(session.list.io.console_output_content).to eq(output)

     ToDoSwitchLists.new.run("w", session)
     session.list.render
     expect(session.list.io.console_output_content).to eq("BACKGROUND" + RENDER_PAD + "\n")
  end

  it 'switches foreground and background' do
     f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     b_io.actions_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
     output_before = RENDER_PAD + [" 0 - L: first\n", " 1   L: second\n",  " 2   L: third\n\n"].join
     output_after  = "BACKGROUND" + RENDER_PAD + [" 0 - R: first\n 1   R: second\n 2   R: third\n\n"].join

     session.list.render
     expect(session.list.io.console_output_content).to eq(output_before)

     ToDoSwitchLists.new.run("w", session)
     session.list.render
     expect(session.list.io.console_output_content).to eq(output_after)
  end

  it 'switches to the background list and moves the cursor to the specified position' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    b_io.actions_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
    output_after  = "BACKGROUND" + RENDER_PAD + [" 0   R: first\n", " 1 - R: second\n", " 2   R: third\n\n"].join

    ToDoSwitchLists.new.run("w 1", session)
    session.list.render
    expect(session.list.io.console_output_content).to eq(output_after)
  end

  it 'does not change the cursor position if no position is specified' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    b_io.actions_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
    output_after  = "BACKGROUND" + RENDER_PAD + [" 0 - R: first\n", " 1   R: second\n", " 2   R: third\n\n"].join

    ToDoSwitchLists.new.run("w", session)
    session.list.render
    expect(session.list.io.console_output_content).to eq(output_after)
  end

end


describe ToDoInsertBlank do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'inserts a blank line at the current cursor position' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    session.list.cursor_set(0)

    ToDoInsertBlank.new.run("i", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - \n 1   L: task AA\n 2   L: task BB\n\n")
  end

  it 'inserts a blank line and maintains the cursor position on the same task' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    session.list.cursor_set(0)

    ToDoInsertBlank.new.run("i", session)
    session.list.down

    expect(session.list.action_at_cursor).to eq("L: task AA") # Cursor should now
  end
end


describe ToDoEditReplace do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'replaces when text to replacement is present' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    session.list.cursor_set(1)

    ToDoEditReplace.new.run("er 2 bb", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0   L: task AA\n 1 - L: task bb\n\n")
  end

  it 'replaces multiple tokens' do
    f_io.actions_content = "L: old task here\n"
    session.list.cursor_set(0)

    ToDoEditReplace.new.run("er 2 new task there", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new task there\n\n")
  end

  it 'replaces tokens until replacements run out' do
    f_io.actions_content = "L: old old old task\n"
    session.list.cursor_set(0)

    ToDoEditReplace.new.run("er 2 new new", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new new task\n\n")
  end

  it 'deletes token at position when no replacement provided' do
    f_io.actions_content = "L: this is a task\n"
    session.list.cursor_set(0)

    ToDoEditReplace.new.run("er 2", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - L: this a task\n\n")
  end
end

describe ToDoZapToTop do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'moves the task at the cursor to position 0' do
    actions = [
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

    f_io.actions_content = actions.join
    session.list.cursor_set(2)
    ToDoZapToTop.new.run("zz", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'does nothing when the cursor is already at position 0' do
    actions = [
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

    f_io.actions_content = actions.join
    session.list.cursor_set(0)
    ToDoZapToTop.new.run("zz", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

end

describe ToDoSaveActions do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }

  it 'saves the actions without quitting' do
    actions_content = "L: task 1\nL: task 2\n"
    f_io.actions_content = actions_content

    ToDoSaveActions.new.run("@", session)

    expect(f_io.actions_content).to eq(actions_content)
  end
end
