require 'spec_helper'
require 'session'
require 'commands/export_html'
require 'fakeappio'

describe ExportHtml do
  let(:io) { FakeAppIo.new }
  let(:session) { Session.from_ios(io, io) }
  let(:command) { ExportHtml.new }

  describe '#matches?' do
    it 'matches the x command' do
      expect(command.matches?("x")).to be true
    end

    it 'matches x with a section name argument' do
      expect(command.matches?("x Projects")).to be true
    end

    it 'does not match other commands' do
      expect(command.matches?("export")).to be false
    end
  end

  describe '#description' do
    it 'returns a CommandDesc' do
      desc = command.description
      expect(desc.name).to eq("x [section]")
      expect(desc.line).to eq("export foreground list (or section) as HTML")
    end
  end

  describe '#process' do
    let(:output_path) { File.expand_path("~/todo.html") }

    after do
      File.delete(output_path) if File.exist?(output_path)
    end

    context 'with plain tasks' do
      before do
        io.tasks_content = "first task\nsecond task\n"
      end

      it 'writes an HTML file to ~/todo.html' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        expect(File.exist?(output_path)).to be true
      end

      it 'includes task text in the HTML output' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("first task")
        expect(html).to include("second task")
      end

      it 'includes proper HTML structure' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("<!DOCTYPE html>")
        expect(html).to include("<title>Todo</title>")
        expect(html).to include("</html>")
      end

      it 'displays the output path' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        expect(io.console_output_content).to include("Wrote")
        expect(io.console_output_content).to include(output_path)
      end
    end

    context 'with tagged tasks' do
      before do
        io.tasks_content = "W: tagged task\n"
      end

      it 'strips the tag from the HTML output' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("tagged task")
        expect(html).not_to include("W:")
      end
    end

    context 'with sections' do
      before do
        io.tasks_content = "#2 Projects\nproject one\nproject two\nplain task\n"
      end

      it 'renders sections as details elements' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("<details")
        expect(html).to include("Projects")
        expect(html).to include("project one")
        expect(html).to include("project two")
      end

      it 'renders children with hierarchical labels' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("0.1")
        expect(html).to include("0.2")
      end

      it 'renders plain tasks alongside sections' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("plain task")
      end
    end

    context 'exporting a single section' do
      let(:section_path) { File.expand_path("~/Projects.html") }

      after do
        File.delete(section_path) if File.exist?(section_path)
      end

      before do
        io.tasks_content = "#2 Projects\nproject one\nproject two\nplain task\n"
      end

      it 'writes a section-specific HTML file' do
        session = Session.from_ios(io, io)
        command.run("x Projects", session)

        expect(File.exist?(section_path)).to be true
      end

      it 'includes only the section children' do
        session = Session.from_ios(io, io)
        command.run("x Projects", session)

        html = File.read(section_path)
        expect(html).to include("project one")
        expect(html).to include("project two")
        expect(html).not_to include("plain task")
      end

      it 'uses the section name as the HTML title' do
        session = Session.from_ios(io, io)
        command.run("x Projects", session)

        html = File.read(section_path)
        expect(html).to include("<title>Projects</title>")
      end

      it 'matches section names by prefix' do
        session = Session.from_ios(io, io)
        command.run("x Proj", session)

        expect(File.exist?(section_path)).to be true
      end

      it 'does nothing when section is not found' do
        session = Session.from_ios(io, io)
        command.run("x Nonexistent", session)

        expect(File.exist?(output_path)).to be false
      end
    end

    context 'with HTML-sensitive characters' do
      before do
        io.tasks_content = "task with <b>html</b> & \"quotes\"\n"
      end

      it 'escapes HTML entities' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("&lt;b&gt;")
        expect(html).to include("&amp;")
        expect(html).to include("&quot;quotes&quot;")
      end
    end

    context 'cursor marking' do
      before do
        io.tasks_content = "first task\nsecond task\n"
      end

      it 'marks the cursor position with an mdash' do
        session = Session.from_ios(io, io)
        command.run("x", session)

        html = File.read(output_path)
        expect(html).to include("&mdash;")
      end
    end
  end
end
