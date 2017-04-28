class Event

  def initialize (success, description, action, direction)
    @success = success
    @description = description
    @action = action
    @direction = direction
  end

  def to_h
    {
      :type => "event",
      :success => @success,
      :description => @description,
      :action => @action,
      :direction => @direction
    }
  end
end