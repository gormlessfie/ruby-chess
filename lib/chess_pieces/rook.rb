# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A rook chess piece. Moves vertically or horizontally, no limit. Can be blocked. 
class Rook < ChessPieces
  def initialize(color, index)
    white_key = create_white_key
    black_key = create_black_key
    super('rook', color, index, white_key, black_key)
  end

  def determine_icon
    black = "\u2656"
    white = "\u265C"

    super(black, white)
  end

  def create_white_key
  end

  def create_black_key
  end
end
