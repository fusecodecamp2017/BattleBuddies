class BBObject

  attr_accessor :type

  def initialize(type = :bb_object)
    @type = type
  end

  def to_h_public
    {
      :type => @type
    }
  end

  def to_h
    {
      :type => @type,
    }
  end

end