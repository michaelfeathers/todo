

class Array
  def swap_elements i, j
    e = self[i]; self[i] = self[j]; self[j] = e
    self
  end

  def freq_by(&block)
    map(&block).tally.sort_by(&:first)
  end

  def freq
    tally.sort_by(&:first)
  end

  def second
    self[1]
  end
end
