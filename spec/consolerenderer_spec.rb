
require 'spec_helper'
require 'consolerenderer'
require 'fakeappio'

describe ConsoleRenderer do
  let(:io) { FakeAppIo.new }
  let(:renderer) { ConsoleRenderer.new }
  let(:tasklist) { double('TaskList') }

  before do
    allow(tasklist).to receive(:io).and_return(io)
    allow(io).to receive(:clear_console)
    allow(io).to receive(:append_to_console)
  end

  describe '#render' do
    it 'clears the console before rendering' do
      allow(tasklist).to receive(:description).and_return("")
      allow(tasklist).to receive(:window).and_return([])

      expect(io).to receive(:clear_console)
      renderer.render(tasklist)
    end

    it 'renders the task list description' do
      description = "Task List\n\n"
      allow(tasklist).to receive(:description).and_return(description)
      allow(tasklist).to receive(:window).and_return([])

      expect(io).to receive(:append_to_console).with(description)
      renderer.render(tasklist)
    end

    it 'renders tasks with proper formatting' do
      window = [
        [0, "-", "L: task 1\n"],
        [1, " ", "L: task 2\n"]
      ]
      allow(tasklist).to receive(:description).and_return("")
      allow(tasklist).to receive(:window).and_return(window)

      expected_output = " 0 \e[41m- L: task 1\n\e[0m" + 
                       " 1   L: task 2\n" +
                       "\n"

      expect(io).to receive(:append_to_console).with("")
      expect(io).to receive(:append_to_console).with(expected_output)
      
      renderer.render(tasklist)
    end

    it 'renders tasks with cursor highlighting' do
      window = [
        [0, "-", "L: task 1\n"],
        [1, "*", "L: task 2\n"],
        [2, " ", "L: task 3\n"]
      ]
      allow(tasklist).to receive(:description).and_return("")
      allow(tasklist).to receive(:window).and_return(window)

      expected_output = " 0 \e[41m- L: task 1\n\e[0m" +
                        " 1 \e[41m* L: task 2\n\e[0m" +
                        " 2   L: task 3\n" +
                        "\n"

      expect(io).to receive(:append_to_console).with("")
      expect(io).to receive(:append_to_console).with(expected_output)
      
      renderer.render(tasklist)
    end

    it 'handles empty task lists' do
      allow(tasklist).to receive(:description).and_return("")
      allow(tasklist).to receive(:window).and_return([])

      expected_output = "\n"

      expect(io).to receive(:append_to_console).with("")
      expect(io).to receive(:append_to_console).with(expected_output)
      
      renderer.render(tasklist)
    end

    it 'handles tasks with varying line numbers' do
      window = [
        [9, "-", "L: task 9\n"],
        [10, " ", "L: task 10\n"]
      ]
      allow(tasklist).to receive(:description).and_return("")
      allow(tasklist).to receive(:window).and_return(window)

     " 0 \e[41m- L: task 1\n\e[0m"  
     expected_output = " 9 \e[41m- L: task 9\n\e[0m"  +
                       "10   L: task 10\n" +
                       "\n"

      expect(io).to receive(:append_to_console).with("")
      expect(io).to receive(:append_to_console).with(expected_output)
      
      renderer.render(tasklist)
    end
  end

end