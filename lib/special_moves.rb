# frozen_string_literal: true

require './lib/board'

# This object will manage all movements done through special moves such as
# Castling, en passant, pawn promotion
class SpecialMoves
  def initialize
    @chess_board = board
  end

  # Castling is done with the rook and king piece.
    # Rook must not have moved
    # King must not have moved
    # King is not in check
    # King must not move over a space that can be attacked by an enemy piece.
    # Squares between the King and the Rook must be empty
    # The King and Rook must occupy the same rank (row)

  # En passant
  # When a pawn makes a double step from the second row to the fourth row and
  # there is an enemy pawn on the adjacent square
  # The enemy pawn make move diagonally to the square that was passed over by
  # the double stepping pawn, the third row.
  # This move must be done directly after the double step move.

  # Pawn Promotion
  # When a pawn reaches the opposite rank (row), white: row 0 ; black: row 7
  # The pawn will promote to any piece the player decides.
end
