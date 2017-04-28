require 'thread'
require './responder'
require './board'
require './player'
require './game'
require './turn_parser'
class GameManager

  def initialize()
    @mutex = Mutex.new
    @p_responders = Array.new
    @o_responders = Array.new
    @turns = Array.new
  end

  def create_game(width = 7, height = 7, number_of_players = 4)
    if is_running?
      stop
    end
    @game = Game.new(width, height, number_of_players)
  end

  def has_game?
    !@game.nil?
  end

  def is_running?
    @playing
  end

  def start(seconds_per_tick = 1, dt=0.1)
    @ticks = 0
    @playing = true
    @game_thread = Thread.new{
      p "Starting game"
      game_loop(seconds_per_tick, dt)
    }
  end

  def stop
    # p "Killing game thread"
    if is_running?
      @playing = false
      @game_thread.exit
      @game_thread.join
    end
    @game = nil
    { :success => true, :message => "Game stopped" }.to_json
  end

  def pause
    @pause = true
  end

  def unpause
    @pause = false
  end

  def game_loop(seconds_per_tick, dt)
    last_tick = Time.now
    while @playing do
      sleep dt
      # p "Waking up"
      # p (Time.now - last_tick).to_s
      # p ((Time.now - last_tick) >= seconds_per_tick).to_s
      if (Time.now - last_tick) >= seconds_per_tick
        # p "Execute tick"
        last_tick += seconds_per_tick
        if !@pause
          game_tick()
        end
      end
    end
  end

  def game_tick()  
    @ticks += 1
    @mutex.synchronize do
      @game.cleanup
      @game.parse_turns(@turns)
      @turns = Array.new
    end
    respond
  end

  def add_p_responder(responder)
    @mutex.synchronize do
      @p_responders << responder
    end
  end

  def add_o_responder(responder)
    @mutex.synchronize do
      @o_responders << responder
    end
  end

  def add_turn(turn)
    @mutex.synchronize do
      @turns << turn
    end
  end

  def add_turn_and_responder(turn, responder)
    add_turn turn
    add_p_responder responder
  end

  def add_observer(responder)
    add_o_responder responder
  end

  def respond
    @mutex.synchronize do
      while @p_responders.length > 0
        r = @p_responders.shift
        r.allow_return
      end
      while @o_responders.length > 0
        r = @o_responders.shift
        r.allow_return
      end
    end
  end

  def display( args = {} )
    {
      :game => @game.display(args)
    }
  end

  def add_player(params)
    name = params[:name]
    player = Player.new(name)

    if player
      @mutex.synchronize do
        @game.add_player player
      end
    end

    player
  end

  def observe( args = {} )
    r = Responder.new()
    add_observer(r)
    { :responder => r }
  end

  def submit_turn(params)
    turn = TurnParser.parse_params(params, @game.players)

    turn.player.add_turn(turn)

    r = Responder.new({:turn => turn})
    add_turn_and_responder(turn, r)
    { :responder => r, :player_id => turn.player.id }
  end

end