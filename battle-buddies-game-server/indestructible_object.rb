require './game_object'

class IndestructibleObject < GameObject

  def initialize
    @type = :indestructible
  end

  def attacked(player, direction)
    "You hit something that didn't even notice your attempt to destroy it"
  end

end