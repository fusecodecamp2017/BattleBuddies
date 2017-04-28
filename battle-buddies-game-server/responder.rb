class Responder

  def initialize(options = {})
    @can_return = false

    if options[:dt]
      @dt = options[:dt]
    else 
      @dt = 0.1
    end

    if options[:turn]
      @turn = options[:turn]
    end

  end

  def wait_and_return
    until @can_return do
      sleep @dt  
    end

    if block_given? 
      yield
    end
  end

  def allow_return
    @can_return = true
  end
end