class HeadlessPaginator
  def initialize(io)
    @io = io
  end

  def display_paginated(content)
    @io.append_to_console(content)
    content
  end
end
