require_relative '../command'
require_relative '../session'


class SectionInsert < Command

  def description
    CommandDesc.new("si text", "move task at cursor into section matching text")
  end

  def matches? line
    (line.split in ["si", *args]) && args.count >= 1
  end

  def process line, session
    text = line.split.drop(1).join(' ')
    session.on_list do |list|
      target = list.find_section_by_name(text)
      return unless target
      return if list.cursor_on_section_header?
      list.section_insert(target)
    end
  end

end
