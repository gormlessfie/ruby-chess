# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A king chess piece. Can move 1 space in any direction. Loses if checkmated
# Can be blocked.
class King < ChessPieces
  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('king', color, index, white_key, black_key)
  end

  def create_key
    [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
  end

  def determine_icon
    black = "\u2654"
    white = "\u265A"
    super(black, white)
  end
end
