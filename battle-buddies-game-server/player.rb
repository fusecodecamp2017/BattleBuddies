require 'securerandom'
require './destructible_object'
require './turn'
require './event'

class Player < DestructibleObject

  attr_accessor :id, :type, :dmg, :defence, :hp, :name, :pos

  def initialize(name, dmg = 1, defence = 4, hp = 4)
    super(:player, hp)

    @id=SecureRandom.uuid
    @public_id=SecureRandom.uuid
    @dmg = dmg
    @defence = defence
    @name = name

    @turns = Array.new
  end

  def attack(target, direction)
    target.attacked(self, direction)
  end

  def miss(direction)
    description = "You swung #{direction} but missed." 
    Event.new(false, description, :attack, direction)
  end

  def attacked(player, direction)
    dmg = player.dmg
    attacking_self = player.id == @id
    shield_broken = @defence <= 0
    blocked = can_block_attack_from(direction)

    defender_success = false
    attacker_success = false

    if blocked
      defender_success = true

      defender_description = "You blocked an attack!"
      attacker_description = "The attack was blocked."

      @defence -= dmg

      if @defence <= 0
        defender_description += " Your shield is broken."
      end
    else
      attacker_success = true

      if attacking_self
        attacker_description = "You attacked yourself for #{dmg} damage. You feel betrayed."
      else
        if shield_broken
          defender_description = "You try to block the attack, but your broken shield fails. You take #{dmg} damage."
        else 
          defender_description = "You were attacked by a player for #{dmg} damage."
        end

        attacker_description = "You swung and hit the player."
      end

      @hp -= dmg
    end

    if is_dead?
      if attacking_self
        attacker_description = attacker_description + " Oh, and you killed yourself."
      else
        defender_description = defender_description + " You are dead!"
        attacker_description = attacker_description + " The player is dead!"
      end
    end

    attacker_event = Event.new(attacker_success, attacker_description, :attack, direction)
    defender_event = attacking_self ? nil : Event.new(defender_success, defender_description, :attacked, Turn.opposite_direction(direction))

    {
      :attacker => attacker_event,
      :defender => defender_event
    }

  end

  def block(direction)
    @block_side = direction
    success = true
    if direction == :none
      description = "You contemplate lifting your shield, but decide against it."
    elsif @defence <= 0
      description = "You hold up your shield, but it's broken state seems discouraging"
      success = false
    else
      description = "You hold your shield #{direction}."
    end

    Event.new(success, description, :defend, direction)
  end

  def can_block_attack_from(direction)
    @block_side != :none && Turn.opposite_direction(direction) == @block_side && @defence > 0
  end

  def unblock
    @block_side = :none
  end

  def wait
    Event.new(true, "You decide to wait and see how this turn plays out.", :wait, :none)
  end

  def to_h_public
    {
      :type => :player,
      :public_id => @public_id,
      :name => @name,
      :hp => @hp,
      :dmg => @dmg,
      :defence => @defence,
      :turns => @turns.map { |turn| turn.to_h }
    }
  end

  def to_h
    h = to_h_public
    adnl = {
      :id => @id,
      :pos => @pos
    }

    h.merge(adnl)
  end

end