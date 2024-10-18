
class TestRenderer 

  attr_reader :rendered_data

  def render list
    @rendered_data = list.window
  end

end