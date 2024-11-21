

class Array
  def swap_elements i, j
    self[i], self[j] = self[j], self[i]
    self
  end

  def freq
    tally.sort_by(&:first)
  end

end
