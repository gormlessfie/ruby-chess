# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A knight chess piece. Moves in L's. Can leap over units. Cannot be blocked.
class Knight < ChessPieces
  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('knight', color, index, white_key, black_key)
    @icon = determine_icon
  end

  def create_key
    [[1, -2], [-2, -1], [-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2]]
  end

  def determine_icon
    black = "\u2658"
    white = "\u265E"

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
