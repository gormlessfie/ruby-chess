# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A king chess piece. Can move 1 space in any direction. Loses if checkmated
# Can be blocked.
class King < ChessPieces
  attr_reader :first_turn

  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('king', color, index, white_key, black_key)
    @first_turn = true
    @check = false
  end

  def create_key
    [[0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1]]
  end

  def determine_icon
    white = "\u2654"
    black = "\u265A"
    super(black, white)
  end

  def update_first_turn_false
    @first_turn = false
  end

  def update_check(condition)
    @check = condition
  end
end
