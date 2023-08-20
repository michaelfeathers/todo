$:.unshift File.dirname(__FILE__)

class Array
  def swap_elements i, j
    e = self[i]; self[i] = self[j]; self[j] = e
    self
  end
end


