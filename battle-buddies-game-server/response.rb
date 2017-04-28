class Response

  def initialize (success, content)
    @success = success
    @content = content
  end

  def to_h 
    {
      :success => @success,
      :content => @content
    }.to_h
  end

  def print
    to_h.to_json
  end

end