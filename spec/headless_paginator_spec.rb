require 'spec_helper'
require 'headless_paginator'

class FakeIo
  attr_accessor :output

  def initialize
    @output = ""
  end

  def append_to_console(text)
    @output += text
  end
end

describe HeadlessPaginator do
  let(:io) { FakeIo.new }
  let(:paginator) { HeadlessPaginator.new(io) }

  describe '#display_paginated' do
    it 'outputs short content directly without pagination' do
      content = "Line 1\nLine 2\nLine 3\n"
      result = paginator.display_paginated(content)

      expect(io.output).to eq(content)
      expect(result).to eq(content)
    end

    it 'outputs long content directly without pagination' do
      content = (1..100).map { |i| "Line #{i}\n" }.join
      result = paginator.display_paginated(content)

      expect(io.output).to eq(content)
      expect(result).to eq(content)
    end

    it 'handles empty content' do
      content = ""
      result = paginator.display_paginated(content)

      expect(io.output).to eq("")
      expect(result).to eq("")
    end

    it 'handles content with special characters' do
      content = "Line with\ttabs\nLine with special: !@#$%\n"
      result = paginator.display_paginated(content)

      expect(io.output).to eq(content)
      expect(result).to eq(content)
    end
  end
end
