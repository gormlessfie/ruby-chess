# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A queen chess piece. The queen can move like rook and bishop combined, no limit.
# Can be blocked.
class Queen < ChessPieces
  def initialize(color, index)
    white_key = create_white_key
    black_key = create_black_key
    super('queen', color, index, white_key, black_key)
  end

  def determine_icon
    black = "\u2655"
    white = "\u265B"

    super(black, white)
  end

  def create_white_key
  end

  def create_black_key
  end
end
