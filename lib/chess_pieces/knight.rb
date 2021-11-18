# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A knight chess piece. Moves in L's. Can leap over units. Cannot be blocked.
class Knight < ChessPieces
  def initialize(color, index)
    white_key = create_white_key
    black_key = create_black_key
    super('knight', color, index, white_key, black_key)
    @icon = determine_icon
  end

  def determine_icon
    black = "\u2658"
    white = "\u265E"

    super(black, white)
  end

  def create_white_key
  end

  def create_black_key
  end
end
