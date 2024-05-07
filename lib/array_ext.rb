$:.unshift File.dirname(__FILE__)

class Array
  def swap_elements i, j
    e = self[i]; self[i] = self[j]; self[j] = e
    self
  end

  def freq_by &block
    group_by(&block).map {|k,v| [k, v.count] }.sort_by(&:first)
  end

  def freq
    freq_by {|e| e }
  end

  def second
    self[1]
  end
end


