require './bb_object'

class GameObject < BBObject

  attr_accessor :type, :turns, :pos

  def initialize(type = :game_object)
    super(type)
    @turns = Array.new
  end

  def add_turn(turn)
    @turns << turn
  end

  def get_latest_turn
    @turns.last
  end

  def to_h_public
    super
  end

  def to_h
    h = super
    
    additional_fields = {
      :turns => @turns
    }

    h.merge(additional_fields)
  end

end