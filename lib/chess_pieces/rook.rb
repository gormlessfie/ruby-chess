# frozen_string_literal: true

class Rook
  def initialize(color)
    @name = 'rook'
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
    white = "\u2656"
    black = "\u265C"

    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end
end
