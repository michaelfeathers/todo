module DateToggleFormatter
  def format_with_date_toggle(content)
    lines = content.lines
    return content if lines.empty?

    formatted_lines = []
    last_date = nil
    use_reverse = false

    lines.each do |line|
      # Extract the date (first word) from the line
      parts = line.split(' ', 2)
      next if parts.empty?

      date = parts[0]
      rest = parts[1] || ""

      # Toggle reverse video when date changes
      if date != last_date
        last_date = date
        use_reverse = !use_reverse
      end

      # Apply formatting to the date only
      if use_reverse
        formatted_lines << "\e[7m#{date}\e[0m #{rest}"
      else
        formatted_lines << "#{date} #{rest}"
      end
    end

    formatted_lines.join
  end
end
