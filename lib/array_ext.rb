

class Array
  def swap_elements i, j
    e = self[i]; self[i] = self[j]; self[j] = e
    self
  end

  def freq
    tally.sort_by(&:first)
  end

end
