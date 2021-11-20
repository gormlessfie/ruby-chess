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
    white = "\u2658"
    black = "\u265E"

    super(black, white)
  end
end
