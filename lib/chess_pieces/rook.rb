# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A rook chess piece. Moves vertically or horizontally, no limit. Can be blocked. 
class Rook < ChessPieces
  def initialize(color, index)
    super('rook', color, index, [[-1, 0], [-2, 0]], [[1, 0], [2, 0]])
  end

  def determine_icon
    black = "\u2656"
    white = "\u265C"

    super(black, white)
  end
end
