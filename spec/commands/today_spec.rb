require 'spec_helper'
require 'session'
require 'commands/today'
require 'fakeappio'
require 'testrenderer'
require 'day'

RENDER_PAD = "\n\n" unless defined?(RENDER_PAD)

describe Today do
  let(:f_io) { FakeAppIo.new }
  let(:b_io) { FakeAppIo.new }
  let(:session) { Session.from_ios(f_io, b_io) }
  let(:o) { rendering_of(session) }

   it'shows the tasks for the current day' do
     f_io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
     f_io.today_content = Day.from_text("2020-01-12")
     Today.new.run("t", session)
     expect(f_io.console_output_content).to eq("\n2020-01-12 R: Thing Y\n\n1\n\n")
   end


   it'shows the tasks for the previous day' do
     f_io.archive_content = "2020-01-11 R: Thing X\n2020-01-12 R: Thing Y\n"
     f_io.today_content = Day.from_text("2020-01-12")
     Today.new.run("t 1", session)
     expect(f_io.console_output_content).to eq("\n2020-01-11 R: Thing X\n\n1\n\n")
   end
end