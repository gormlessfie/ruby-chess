# frozen_string_literal: true

class Pawn
  def initialize(color)
    @name = 'pawn'
    @color = color
    @current_pos = find_pos
    @possible_moves = update_possible_moves
  end

  def find_pos
  end

  def update_possible_moves
  end
end
