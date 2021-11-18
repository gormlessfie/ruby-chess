# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A knight chess piece. Moves in L's. Can leap over units. Cannot be blocked.
class Knight < ChessPieces
  def initialize(color, index)
    super('knight', color, index, [[-1, 0], [-2, 0]], [[1, 0], [2, 0]])
    @icon = determine_icon
  end

  def determine_icon
    black = "\u2658"
    white = "\u265E"

    super(black, white)
  end
end
