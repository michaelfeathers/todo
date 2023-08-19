$:.unshift File.dirname(__FILE__)

require 'session'
require 'fakeappio'

empty_archive_expected = "

             R7K    Globant       Life      Total

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

Today          0          0          0          0


"

describe Session do
  it 'finds simple text' do
    io = FakeAppIo.new
    io.actions_content = "L: task AA\nL: task BB\n"
    session = Session.new(io)
    expect(session.find("AA")).to eq([" 0 L: task AA\n"])
  end

  it 'ignores case when it finds' do
    io = FakeAppIo.new
    io.actions_content = "L: task A\nL: task B\n" 
    session = Session.new(io)
    expect(session.find("b")).to eq([" 1 L: task B\n"])
  end

  it 'produces a summary for an empty archive' do
    io = FakeAppIo.new
    io.actions_content = "L: task A\nL: task B\n"
    session = Session.new(io)
    session.todo_month_summaries
    expect(io.console_content).to eq(empty_archive_expected)
  end

  it 'shows archive entries of today' do
    io = FakeAppIo.new
    io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
    io.today_content = Day.from_text("2020-01-12")
    session = Session.new(io)
    session.todo_today
    expect(io.console_content).to eq("2020-01-12 R: Thing Y\n\n")
  end

  xit 'renders two tasks' do
    io = FakeAppIo.new
    io.actions_content = "L: Do something\nR: Do another thing\n"
    session = Session.new(io)
    session.render
    expect(io.console_content).to eq("A")
  end
end
