# frozen_string_literal: true

class Pawn
  def initialize(color, index)
    @name = 'pawn'
    @color = color
    @current_pos = index
    @possible_moves = update_possible_moves
    @icon = determine_icon
    @first_turn = true
  end

  def update_possible_moves

  end

  def update_first_turn_false
    @first_turn = false
  end

  def determine_icon
    black = "\u2659"
    white = "\u265F"

    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end

  def display_icon
    @icon
  end
end
