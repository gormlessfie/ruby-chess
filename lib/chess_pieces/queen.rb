# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A queen chess piece. The queen can move like rook and bishop combined, no limit.
# Can be blocked.
class Queen < ChessPieces
  def initialize(color, index)
    super('queen', color, index, [[-1, 0], [-2, 0]], [[1, 0], [2, 0]])
  end

  def determine_icon
    black = "\u2655"
    white = "\u265B"

    super(black, white)
  end
end
