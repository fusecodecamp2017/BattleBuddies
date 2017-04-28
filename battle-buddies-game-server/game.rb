require 'thread'
require './bb_object'
require './board'
require './player'

class Game < BBObject

  attr_reader :players

  def initialize(width, height, number_of_players)
    super(:game)
    @turn_mutex = Mutex.new
    @board_mutex = Mutex.new
    @board = Board.new(width, height, number_of_players)
    @players = Hash.new()
  end

  def add_player(player)
    # if(@players.length < @board.number_of_players)
      @players[player.id] = player
      alive_players = @players.select { |k, player| !player.is_dead? }.map { |k, player| player }
      @board.players = alive_players
      @board.put_in_starting_position(player)
    # else
      # false
    # end
  end

  def display(options = {})
    if options.size == 0
      to_h_public
    else
      h = to_h
      player_id = options[:player_id]
      player_hash = @players[player_id].to_h
      
      h.merge({
        :player => player_hash  
      })
    end
  end

  def parse_turns(turns)
    @turn_mutex.synchronize do 

      alive_players = @players.select { |k, player| !player.is_dead? }.map { |k, player| player }
      @board.players = alive_players

      turns.each do |turn|
        if !turn.player.is_dead?
          case turn.p_action
            when :move
              # "Player is moving"
              player_move(turn)
            when :attack
              # "Player is attacking"
              player_attack(turn)
            when :defend
              # "Player is defending"
              player_defend(turn)
            else
              # Do nothing
              player_wait(turn.player)
          end
        end
      end
    end
  end


  def player_move(turn)
    @board_mutex.synchronize do 
      event = @board.move(turn.player, turn.direction)
      turn.add_event(event)
    end
  end

  def player_attack(turn)
    player = turn.player
    direction = turn.direction 

    obj = @board.get_object_relative_to_player(player, direction)

    if obj.nil?
      p_event = player.miss(direction)
    else
      events = player.attack(obj, direction)
      a_event = events[:attacker]
      d_event = events[:defender]
    end

    turn.add_event(a_event)

    if d_event != nil
      d_turn = obj.get_latest_turn
      if d_turn != nil
        d_turn.add_event(d_event)
      end
    end
  end

  def player_defend(turn)
    player = turn.player
    direction = turn.direction

    event = player.block(direction)
    turn.add_event(event)
  end

  def player_wait(turn)
    turn.add_event(turn.player.wait)
  end

  def cleanup
    @turn_mutex.synchronize do
      @players.each do |key, player|
        if player.is_dead?
          @board.remove_player(player)
        end

        player.unblock
      end
    end
  end

  def to_h
    h = super

    addn = {
      :board => @board.to_h,
    }

    h.merge(addn)
  end

  def to_h_public
    h = to_h
    players = @players.select { |k, player| !player.is_dead? }.map { |k, player| player.to_h }
    deceased = @players.select { |k, player| player.is_dead? }.map { |k, player| player.to_h }
    addn = {
        :players => players,
        :deceased => deceased
    }

    h.merge(addn)
  end

end