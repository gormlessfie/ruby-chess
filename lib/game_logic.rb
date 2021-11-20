# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
class GameLogic
  def initialize(board)
    @chess_board = board
    @list_of_white_pieces = @chess_board.get_list_of_pieces('white')
    @list_of_black_pieces = @chess_board.get_list_of_pieces('black')
  end

  def determine_check
    # A king is in check when it is on a possible move space of an opposite
    # color piece.
  end

  def determine_checkmate
    # A checkmate is decided when a king is checked and has no possible moves
    # without going into another check.
  end

  def determine_tie
    # A tie is decided when...
  end
end
