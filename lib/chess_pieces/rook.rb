# frozen_string_literal: true

class Rook
  def initialize(color)
    @name = 'rook'
    @color = color
    @current_pos = find_pos
    @possible_moves = update_possible_moves
  end

  def find_pos
  end

  def update_possible_moves
  end
end
