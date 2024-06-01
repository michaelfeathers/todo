$:.unshift File.dirname(__FILE__)

require 'spec_helper'
require 'session'
require 'commands'
require 'fakeappio'

RENDER_PAD = "\n\n"

describe ToDoAdd do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  describe '#run' do
    it 'adds a new task to the beginning of the list' do
      ToDoAdd.new.run('a New task', session)
      expect(session.list.action_at_cursor).to eq('New task')
    end

    it 'sets the cursor to the newly added task' do
      ToDoAdd.new.run('a New task', session)
      ToDoAdd.new.run('a Another task', session)
      expect(session.list.action_at_cursor).to eq('Another task')
    end

    it 'trims leading and trailing whitespace from the task text' do
      ToDoAdd.new.run('a   Task with whitespace   ', session)
      expect(session.list.action_at_cursor).to eq('Task with whitespace')
    end

    it 'does not add an empty task' do
      ToDoAdd.new.run('a', session)
      expect(session.list.action_at_cursor).to eq('')
    end

    it 'adds multiple tasks in the correct order' do
      ToDoAdd.new.run('a Task 1', session)
      ToDoAdd.new.run('a Task 2', session)
      ToDoAdd.new.run('a Task 3', session)

      expect(session.list.action_at_cursor).to eq('Task 3')
      session.list.todo_down
      expect(session.list.action_at_cursor).to eq('Task 2')
      session.list.todo_down
      expect(session.list.action_at_cursor).to eq('Task 1')
    end
  end

  describe '#matches?' do
    it 'matches a command starting with "a"' do
      expect(ToDoAdd.new.matches?('a New task')).to be_truthy
    end

    it 'does not match a command not starting with "a"' do
      expect(ToDoAdd.new.matches?('x New task')).to be_falsey
    end
  end
end

describe ToDoMoveTaskToOther do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  describe '#run' do
    it 'moves the task at the cursor from the foreground list to the background list' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      session.list.todo_cursor_set(1)

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("Task 1\nTask 3\n")
      expect(b_io.actions_content).to eq("Task 2\n")
    end

    it 'moves the task at the cursor from the background list to the foreground list' do
      b_io.actions_content = "Task A\nTask B\nTask C\n"
      session.switch_lists
      session.list.todo_cursor_set(1)

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("Task B\n")
      expect(b_io.actions_content).to eq("Task A\nTask C\n")
    end

    xit 'does not modify the lists if the foreground list is empty' do
      f_io.actions_content = ""
      b_io.actions_content = "Task A\nTask B\nTask C\n"

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("")
      expect(b_io.actions_content).to eq("Task A\nTask B\nTask C\n")
    end

    xit 'does not modify the lists if the background list is empty' do
      f_io.actions_content = "Task 1\nTask 2\nTask 3\n"
      b_io.actions_content = ""
      session.switch_lists

      ToDoMoveTaskToOther.new.run('-', session)
      session.save

      expect(f_io.actions_content).to eq("Task 1\nTask 2\nTask 3\n")
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

describe ToDoRemove do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

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
  let(:session) { Session.new(f_io, b_io) }

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

describe ToDoCursorToStart do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'moves the cursor to the 0th task when not already there' do
    actions = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n"
    ]
    output = actions.map.with_index do |action, i|
      cursor = i.zero? ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]
    end.join

    f_io.actions_content = actions.join
    session.list.todo_cursor_set(2)
    ToDoCursorToStart.new.run("cc", session)
    session.list.render
    
    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

  it 'does nothing when cursor is already at 0th task' do
    actions = [
      "L: task 0\n",
      "L: task 1\n",
      "L: task 2\n" 
    ]
    output = actions.map.with_index do |action, i|
      cursor = i.zero? ? '-' : ' '
      "%2d %s %s" % [i, cursor, action]  
    end.join
    
    f_io.actions_content = actions.join
    session.list.render
    ToDoCursorToStart.new.run("cc", session)
    
    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end
end

describe ToDoIterativeFind do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

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
    session.list.todo_cursor_set(1)
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
    session.list.todo_cursor_set(1)
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
    session.list.todo_cursor_set(1)
    ToDoIterativeFind.new.run("ff token", session)
    ToDoIterativeFind.new.run("ff", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

end


describe ToDoPageUp do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }


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
  let(:session) { Session.new(f_io, b_io) }

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

describe ToDoCursorSet do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }


  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE + 5
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,n == pos ? "-" : " " ,n] }
    f_io.actions_content = actions.join 
    ToDoCursorSet.new.run("c #{pos}", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end
end

describe ToDoDown do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE  - 1
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,n == (pos + 1) ? "-" : " " ,n] }
    f_io.actions_content = actions.join 
    ToDoCursorSet.new.run("c #{pos}", session)
    ToDoDown.new.run("d", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end
end

describe ToDoUp do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'pages when cursor set off page' do
    pos = TaskList::PAGE_SIZE - 1
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,n == pos ? "-" : " " ,n] }
    f_io.actions_content = actions.join 
    ToDoPageDown.new.run("dd", session)
    ToDoCursorSet.new.run("c #{pos}", session)
    ToDoUp.new.run("d", session)
    session.list.render
    expect(f_io.console_output_content).to eq(RENDER_PAD + output.take(TaskList::PAGE_SIZE).join + "\n")
  end
end


describe ToDoZapToPosition do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

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
    ToDoCursorSet.new.run("c 1", session)
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
  let(:session) { Session.new(f_io, b_io) }

  it 'retags an L to an R' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output =  RENDER_PAD + [ " 0   L: first\n", " 1 - R: second\n",  " 2   L: third\n\n"].join    
    ToDoCursorSet.new.run("c 1", session)
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
  let(:session) { Session.new(f_io, b_io) }

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
  let(:session) { Session.new(f_io, b_io) }

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
  let(:session) { Session.new(f_io, b_io) }

  it 'inserts a blank line at the current cursor position' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    session.list.todo_cursor_set(0) 

    ToDoInsertBlank.new.run("i", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - \n 1   L: task AA\n 2   L: task BB\n\n")
  end

  it 'inserts a blank line and maintains the cursor position on the same task' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    session.list.todo_cursor_set(0) 

    ToDoInsertBlank.new.run("i", session)
    session.list.todo_down 

    expect(session.list.action_at_cursor).to eq("L: task AA") # Cursor should now
  end 
end


describe ToDoEditReplace do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'replaces when text to replacement is present' do
    f_io.actions_content = "L: task AA\nL: task BB\n"
    session.list.todo_cursor_set(1) 

    ToDoEditReplace.new.run("er 2 bb", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0   L: task AA\n 1 - L: task bb\n\n")
  end

  it 'replaces multiple tokens' do
    f_io.actions_content = "L: old task here\n"
    session.list.todo_cursor_set(0)

    ToDoEditReplace.new.run("er 2 new task there", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new task there\n\n")
  end

  it 'replaces tokens until replacements run out' do
    f_io.actions_content = "L: old old old task\n"
    session.list.todo_cursor_set(0)

    ToDoEditReplace.new.run("er 2 new new", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - L: old new new task\n\n")
  end

  it 'deletes token at position when no replacement provided' do
    f_io.actions_content = "L: this is a task\n"
    session.list.todo_cursor_set(0)

    ToDoEditReplace.new.run("er 2", session)
    session.list.render

    expect(f_io.console_output_content).to eq("\n\n 0 - L: this a task\n\n")
  end
end
 
describe ToDoZapToTop do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

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
    session.list.todo_cursor_set(2)
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
    session.list.todo_cursor_set(0)
    ToDoZapToTop.new.run("zz", session)
    session.list.render

    expect(f_io.console_output_content).to eq(RENDER_PAD + output + "\n")
  end

end

describe ToDoSaveActions do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'saves the actions without quitting' do
    actions_content = "L: task 1\nL: task 2\n"
    f_io.actions_content = actions_content

    ToDoSaveActions.new.run("@", session)

    expect(f_io.actions_content).to eq(actions_content)
  end
end

