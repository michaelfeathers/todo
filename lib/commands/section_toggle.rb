require_relative '../command'
require_relative '../session'


class SectionToggle < Command

  def description
    CommandDesc.new("(enter)", "toggle section collapse when on section header")
  end

  def run line, session, result = CommandResult.new
    return unless session.list.cursor_on_section_header?
    return unless matches?(line)
    result.record_match(self)
    process line, session
  end

  def matches? line
    line.strip.empty?
  end

  def process line, session
    session.on_list {|list| list.section_toggle }
  end

end
