# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A bishop chess piece. Moves diagonally, no limit. Can be blocked.
class Bishop < ChessPieces
  def initialize(color, index)
    white_key = create_white_key
    black_key = create_black_key
    super('bishop', color, index, white_key, black_key)
  end

  def determine_icon
    black = "\u2657"
    white = "\u265D"

    super(black, white)
  end

  def create_white_key
  end

  def create_black_key
  end
end
