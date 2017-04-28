require "./turn"

class TurnParser

  @actions = {
    "wait" => :wait,
    "move" => :move,
    "attack" => :attack,
    "defend" => :defend
  }

  @directions=  {
    "none" => :none,
    "up" => :up,
    "down" => :down,
    "left" => :left,
    "right" => :right
  }

  def self.parse_params (params, players)
    if !params.nil?
      player_id = params[:player_id]
      Turn.new(
        parse_action(params[:action]),
        parse_direction(params[:direction]),
        parse_player_id(player_id, players)
      )
    end
  end

  def self.parse_action (action_str)
    @actions[action_str.downcase]
  end

  def self.parse_direction (direction_str)
    @directions[direction_str.downcase]
  end

  def self.parse_player_id (player_id, players)
    players[player_id]
  end

end