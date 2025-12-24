module DateToggleFormatter
  def format_with_date_toggle(content)
    lines = content.lines
    return content if lines.empty?

    lines
      .map { |line| line.split(' ', 2) }
      .reject(&:empty?)
      .chunk { |line_parts| line_parts.first }
      .with_index
      .flat_map { |(date, span_lines), span_index|
        reverse_video = span_index.even?
        span_lines.map { |line_parts|
          line_text = line_parts[1] || ""
          reverse_video ? "\e[7m#{date}\e[0m #{line_text}" : "#{date} #{line_text}"
        }
      }
      .join
  end
end
