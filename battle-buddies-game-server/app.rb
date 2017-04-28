require 'rubygems'
require 'bundler'
require 'pry'

Bundler.require

require './game_manager'
require './response'

class App < Sinatra::Application

  configure do
    set :show_exceptions, true
    enable :dump_errors,:raise_errors
    use Rack::ShowExceptions
  end
  
  before do
    content_type :json

    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Authorization,Accepts,Content-Type,X-CSRF-Token,X-Requested-With'
    headers 'Access-Control-Allow-Methods' => 'GET,POST,PUT,DELETE,OPTIONS'
  end

  def gm?
    !(defined?(@@gm)).nil?
  end

  def create_gm_if_nil
    if !gm?
      @@gm = GameManager.new()
    end
  end

  def fail_if_gm_nil
    if !gm?
      halt(500, Response.new(false, "Game Manager has not been created").print)
    end
  end

  get '/' do
    Response.new(true, { :message => "Welcome to Battle Bots!" }).print
  end

  get '/game' do
    fail_if_gm_nil
    gm_response = @@gm.observe

    r = gm_response[:responder]

    r.wait_and_return {
      Response.new(true, @@gm.display).print
    }
  end

  post '/game' do
    create_gm_if_nil
    @@gm.create_game
    
    Response.new(true, "Game created!").print
  end

  delete '/game' do
    fail_if_gm_nil
    @@gm.stop
  end

  post '/game/start' do
    create_gm_if_nil
    if @@gm.has_game?
      @@gm.start
      Response.new(true, { :message => "Game started!"}).print
    else
      Response.new(false, { :message => "Game not yet created"}).print
    end
  end

  post '/game/pause' do
    fail_if_gm_nil
    @@gm.pause
    Response.new(true, "Game paused").print
  end

  post '/game/unpause' do
    fail_if_gm_nil
    @@gm.unpause
    Response.new(true, "Game unpaused").print
  end

  post '/player' do
    fail_if_gm_nil

    # if @@gm.is_running?
      # Response.new(false, "Game in progress").print
    # else
      player = @@gm.add_player(params)
      if player
        Response.new(true, player.to_h).print
      else
        Response.new(false, "Maximum number of players reached").print
      end
    # end
  end

  post '/game/turn' do
    fail_if_gm_nil
    gm_response = @@gm.submit_turn(params)

    r = gm_response[:responder]
    pid = gm_response[:player_id]

    r.wait_and_return {
      Response.new(true, @@gm.display({:player_id => pid})).print
    }
  end

end


# get '/game/start' do

#   if game?
#     @@gm.stop
#   end
#   @@gm = GameManager.new
#   @@gm.start

#   "New game started"
# end

# get '/game/stop' do
#   if !(defined?(@@gm)).nil?
#     @@gm.stop
#   end

#   "Stopping game"
# end


# get '/game/turn' do
#   r = Responder.new
#   p "New responder"
#   @@gm.add_responder(r)
#   r.wait_and_return {
#     p "Has responded"
#     @@gm.display
#   }
# end

# post '/game/turn' do
#   r = Responder.new
#   turn = TurnParser.parse_params(params)
#   @@gm.submit_turn(turn)
#   @@gm.add_responder(r)
  
#   r.wait_and_return {
#     p "Has responded"
#     @@gm.display
#   }
# end


# get '/player/add' do
#   if game?
#     p = @@gm.add_player
#     {
#       success: true,
#       id: p.id
#     }.to_json
#   else
#     halt(500, {
#         success: false,
#         reason: "No active game"
#       }.to_json)
#   end
# end


# def game? 
#   !(defined?(@@gm)).nil?
# end
