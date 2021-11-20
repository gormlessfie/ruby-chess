# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
class GameLogic
  def initialize(board)
    @chess_board = board
  end

  def determine_check
    # A king is in check when it is on a possible move space of an opposite
    # color piece.
  end

  def determine_checkmate
  end

  def determine_tie
  end
end
