# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A king chess piece. Can move 1 space in any direction. Loses if checkmated
# Can be blocked.
class King < ChessPieces
  def initialize(color, index)
    super('king', color, index, [[-1, 0], [-2, 0]], [[1, 0], [2, 0]])
  end

  def determine_icon
    black = "\u2654"
    white = "\u265A"

    super(black, white)
  end
end
