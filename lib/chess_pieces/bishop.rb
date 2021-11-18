# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A bishop chess piece. Moves diagonally, no limit. Can be blocked.
class Bishop < ChessPieces
  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('bishop', color, index, white_key, black_key)
  end

  def create_key
    [[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end

  def determine_icon
    black = "\u2657"
    white = "\u265D"
    super(black, white)
  end

  def possible_moves_helper(key, current_position)
    key.map do |possible_move|
      pos_row = possible_move[0] + current_position[0]
      pos_col = possible_move[1] + current_position[1]
      next unless pos_row.between?(0, 7) && pos_col.between?(0, 7)

      [pos_row, pos_col]
    end
  end
end
