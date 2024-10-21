
class TestRenderer 

  attr_reader :rendered_data

  def render list
    @rendered_data = list.window
  end

end

def rendering_of session
  target = TestRenderer.new
  session.render(target)

  target.rendered_data
end