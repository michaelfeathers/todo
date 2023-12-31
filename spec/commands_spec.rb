$:.unshift File.dirname(__FILE__)

require 'session'
require 'commands'
require 'fakeappio'

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
    expect(f_io.console_output_content).to eq(output.take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'shows the second page of tasks' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join 
    ToDoPageDown.new.run("dd", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'is noop when on the last page' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join 
    ToDoPageDown.new.run("dd", session)
    ToDoPageDown.new.run("dd", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
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
    expect(f_io.console_output_content).to eq(output.take(TaskList::PAGE_SIZE).join + "\n")
  end

  it 'shows the first page of tasks after previously paging down' do
    actions =  50.times.map {|n| "L: task #{n}\n" }
    output  =  50.times.map {|n| "%2d %s L: task %d\n" % [n,cursor_char(n),n] }
    f_io.actions_content = actions.join 
    ToDoPageDown.new.run("dd", session)
    ToDoPageUp.new.run("uu", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output.take(TaskList::PAGE_SIZE).join + "\n")
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
    expect(f_io.console_output_content).to eq(output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
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
    expect(f_io.console_output_content).to eq(output.drop(TaskList::PAGE_SIZE).take(TaskList::PAGE_SIZE).join + "\n")
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
    expect(f_io.console_output_content).to eq(output.take(TaskList::PAGE_SIZE).join + "\n")
  end
end

describe ToDoZapToPosition do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'zaps the item at zero to one' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output = [" 0 - L: second\n", " 1   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 1", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)

  end

  it 'saturates when asked to zap outside the range high' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output = [" 0 - L: second\n", " 1   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 2", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)

  end

  it 'saturates when asked to zap outside the range low' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output = [" 0   L: second\n", " 1 - L: first\n\n"].join
    ToDoCursorSet.new.run("c 1", session)
    ToDoZapToPosition.new.run("z -1", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)

  end

  it 'noops when asked to zap to the same position' do
    f_io.actions_content = [ "L: first\n", "L: second\n"].join
    output = [" 0 - L: first\n", " 1   L: second\n\n"].join
    ToDoZapToPosition.new.run("z 0", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
  end

  it 'has insertion rather than swap aemantics' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output = [" 0 - L: second\n", " 1   L: third\n 2   L: first\n\n"].join
    ToDoZapToPosition.new.run("z 2", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
  end

end

describe ToDoSurface do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'surfaces a single task' do
    f_io.actions_content = (0..9).to_a.map { |n| "#{n}\n" }.join($/)
    ToDoSurface.new.run("su", session)
    session.list.render
    expect(f_io.console_output_content.split.map(&:to_i)).to_not eq((0..9).to_a)
  end

end

describe ToDoReTag do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'retags an L to an R' do
    f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
    output = [ " 0   L: first\n", " 1 - R: second\n",  " 2   L: third\n\n"].join    
    ToDoCursorSet.new.run("c 1", session)
    ToDoReTag.new.run("rt r", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
  end

  it'does nothing when regtagging in an empty task list' do
    f_io.actions_content = "" 
    output = "\n" 
    ToDoReTag.new.run("rt r", session)
    session.list.render
    expect(f_io.console_output_content).to eq(output)
   end

   it'adds a tag to a task with no tag' do
     f_io.actions_content = ["first\n"].join
     output = " 0 - L: first\n\n" 
     ToDoReTag.new.run("rt l", session)
     session.list.render
     expect(f_io.console_output_content).to eq(output)
   end

   it'does nothing when no new tag is supplied' do
     f_io.actions_content = ["R: first\n"].join
     output = " 0 - R: first\n\n" 
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
     session.list.render
     expect(f_io.console_output_content).to eq("2020-01-12 R: Thing Y\n\n\n")
   end


   it'shows the tasks for the previous day' do
     f_io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
     f_io.today_content = Day.from_text("2020-01-12")
     output = " 0 - R: first\n\n" 
     ToDoToday.new.run("t 1", session)
     session.list.render
     expect(f_io.console_output_content).to eq("2020-01-11 R: Thing X\n\n\n")
   end

end


describe ToDoSwitchLists do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.new(f_io, b_io) }

  it 'switches away foreground' do
     f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     output = [ " 0 - L: first\n", " 1   L: second\n",  " 2   L: third\n\n"].join    
     session.list.render
     expect(session.list.io.console_output_content).to eq(output)

     ToDoSwitchLists.new.run("w", session)
     session.list.render
     expect(session.list.io.console_output_content).to eq("\n")
  end

  it 'switches foreground and background' do
     f_io.actions_content = [ "L: first\n", "L: second\n",  "L: third\n"].join
     b_io.actions_content = [ "R: first\n", "R: second\n",  "R: third\n"].join
     output_before = [ " 0 - L: first\n", " 1   L: second\n",  " 2   L: third\n\n"].join    
     output_after  = [ " 0 - R: first\n", " 1   R: second\n",  " 2   R: third\n\n"].join    
     session.list.render
     expect(session.list.io.console_output_content).to eq(output_before)

     ToDoSwitchLists.new.run("w", session)
     session.list.render
     expect(session.list.io.console_output_content).to eq(output_after)
  end
  
  


end
 

