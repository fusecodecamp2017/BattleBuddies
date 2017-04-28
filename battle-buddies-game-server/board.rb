require './bb_object'
require './player'
require './indestructible_object'

class Board < BBObject
  attr_reader :width, :height, :number_of_players, :positions

  def initialize(width, height, number_of_players)
    super(:board)
    @width = width
    @height = height
    @number_of_players = number_of_players
    @board = Array.new(width) {Array.new(height)}
    @starting_positions = create_starting_positions
    @positions = Hash.new
  end

  def create_starting_positions
    starts = Array.new

    if @number_of_players == 4
      starts.push( {:x => 0, :y => 0} )
      starts.push( {:x => @width - 1, :y => 0} )
      starts.push( {:x => @width - 1, :y => @height - 1} )
      starts.push( {:x => 0, :y => @height - 1} )
    end

    starts
  end

  def random_position
    {
      :x => rand(@width),
      :y => rand(@height)
    }
  end

  def put_in_starting_position(player)
    pos = random_position

    while @board[pos[:x]][pos[:y]] != nil
      pos = random_position
    end

    @board[pos[:x]][pos[:y]] = player
    player.pos = pos
    @positions[player.id] = pos
  end

  def move(player, direction)
    cur_pos = @positions[player.id]
    cur_x = cur_pos[:x]
    cur_y = cur_pos[:y]
    new_x = cur_x
    new_y = cur_y

    result = Hash.new   

    case direction
      when :up
        if cur_y == 0 
          description = "You try to move #{direction}, but you instead ran into the wall"
        elsif !is_accessible(cur_x, cur_y - 1)
          description = "You try to move #{direction}, but someone was in your way"
        else
          description = "You move #{direction} a space"
          new_y = cur_y - 1
        end
      when :down
        if cur_y == @height - 1 
          description = "You try to move #{direction}, but you instead ran into the wall"
        elsif !is_accessible(cur_x, cur_y + 1) 
          description = "You try to move #{direction}, but someone was in your way"
        else
          description = "You move #{direction} a space"
          new_y = cur_y + 1
        end
      when :left
        if cur_x == 0 
          description = "You try to move #{direction}, but you instead ran into the wall"
        elsif !is_accessible(cur_x - 1, cur_y) 
          description = "You try to move #{direction}, but someone was in your way"
        else
          description = "You move #{direction} a space"
          new_x = cur_x - 1
        end
      when :right
        if cur_x == @width - 1 
          description = "You try to move #{direction}, but you instead ran into the wall"
        elsif !is_accessible(cur_x + 1, cur_y) 
          description = "You try to move #{direction}, but someone was in your way"
        else
          description = "You move #{direction} a space"
          new_x = cur_x + 1
        end
      else
        description = "Maybe standing still is a good idea. Maybe not."
        # Don't move
    end

    new_pos = {:x => new_x, :y => new_y}

    if new_pos == cur_pos
      event = Event.new(false, description, :move, direction)
    else
      clear_tile_at(cur_x, cur_y)
      put_player_at(player, new_x, new_y)
      @positions[player.id] = new_pos
      event = Event.new(true, description, :move, direction)
    end

    event
  end

  def get_at(x, y)
    @board[x][y]
  end

  def get_object_relative_to_player(player, direction)
    cur_pos = @positions[player.id]
    cur_x = cur_pos[:x]
    cur_y = cur_pos[:y]

    obj = nil

    case direction
      when :up
        if cur_y == 0
          obj = IndestructibleObject.new
        elsif is_occupied(cur_x, cur_y - 1)
          obj = get_at(cur_x, cur_y - 1)
        end
      when :down
        if cur_y == @height - 1
          obj = IndestructibleObject.new
        elsif is_occupied(cur_x, cur_y + 1)
          obj = get_at(cur_x, cur_y + 1)
        end
      when :left
        if cur_x == 0
          obj = IndestructibleObject.new
        elsif is_occupied(cur_x - 1, cur_y)
          obj = get_at(cur_x - 1, cur_y)
        end
      when :right
        if cur_x == @width - 1
          obj = IndestructibleObject.new
        elsif is_occupied(cur_x + 1, cur_y)
          obj = get_at(cur_x + 1, cur_y)
        end
      else
        obj = player
    end

    obj

  end

  def clear_tile_at(x, y)
    @board[x][y] = nil
  end

  def put_player_at(player, x, y)
    @board[x][y] = player
    player.pos = {:x => x, :y => y}
  end

  def remove_player(player)
    cur_pos = @positions[player.id]
    clear_tile_at(cur_pos[:x], cur_pos[:y])
  end

  def is_accessible(x, y)
    get_at(x, y) == nil
  end

  def is_occupied (x, y)
    !is_accessible(x, y)
  end

  def hash_board
    h_board = Array.new()

    @board.each_with_index do |row, x|
      h_row = Array.new()
      row.each_with_index do |element, y|
        if element.nil?
          h_row.insert(y, nil)
        else
          h_row.insert(y, element.to_h_public)
        end
      end
      h_board.insert(x, h_row)
    end

    h_board
  end

  def to_h
    h = super
    additional_params = {
      :grid => hash_board,
      :width => @width,
      :height => @height,
      :max_players => @number_of_players
    }

    h.merge(additional_params)
  end

end