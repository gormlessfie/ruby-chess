# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A bishop chess piece. Moves diagonally, no limit. Can be blocked.
class Bishop < ChessPieces
  def initialize(color, index)
    super('bishop', color, index, [[-1, 0], [-2, 0]], [[1, 0], [2, 0]])
  end

  def determine_icon
    black = "\u2657"
    white = "\u265D"

    super(black, white)
  end
end
