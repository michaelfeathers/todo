module DateToggleFormatter
  def format_with_date_toggle(content)
    lines = content.lines
    return content if lines.empty?

    lines
      .map { |line| line.split(' ', 2) }
      .reject(&:empty?)
      .chunk { |words| words.first }
      .with_index
      .flat_map { |(date, lines), line_index|
        reverse_video = line_index.even?
        lines.map { |line|
          line_text = line[1] || ""
          reverse_video ? "\e[7m#{date}\e[0m #{line_text}" : "#{date} #{line_text}"
        }
      }
      .join
  end
end
