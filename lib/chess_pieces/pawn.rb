# frozen_string_literal: true

class Pawn
  def initialize(color)
    @name = 'pawn'
    @color = color
    @current_pos = find_pos
    @possible_moves = update_possible_moves
    @icon = determine_icon
  end

  def find_pos
  end

  def update_possible_moves
  end

  def determine_icon
    black = "\u2659"
    white = "\u265F"

    @color == 'white' ? white_pawn.encode('utf-8') : black_pawn.encode('utf-8')
  end

  def display_icon
    @icon
  end
end
