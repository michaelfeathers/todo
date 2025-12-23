module DateToggleFormatter
  def format_with_date_toggle(content)
    lines = content.lines
    return content if lines.empty?

    lines
      .map { |line| line.split(' ', 2) }
      .reject(&:empty?)
      .chunk { |parts| parts.first }
      .with_index
      .flat_map { |(date, parts_group), chunk_index|
        use_reverse = chunk_index.even?
        parts_group.map { |parts|
          rest = parts[1] || ""
          use_reverse ? "\e[7m#{date}\e[0m #{rest}" : "#{date} #{rest}"
        }
      }
      .join
  end
end
