# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
# This object should be created and ran before player chooses piece to move.
class GameLogic
  def initialize(board)
    @chess_board = board
    @list_of_white_pieces = @chess_board.get_list_of_pieces('white')
    @list_of_black_pieces = @chess_board.get_list_of_pieces('black')
  end

  def determine_check_king_of(king_color)
    # A king is in check when it is on a possible move space of an opposite
    # color piece.

    # Check all enemy piece's possible move list and see if any of them contain
    # the position of the king.

    # Get list of enemy pieces
    list = king_color.match('white') ? @list_of_black_pieces : @list_of_white_pieces

    # Get king to be checked
    king = @list_of_white_pieces.select { |piece| piece.name.match('king') }

    # Enumerate through each opponent piece and check possible_moves of each
    # and see if any contains the position of the king.
    list.each do |opponent_piece|
      list_of_possible_moves = opponent_piece.possible_moves.flatten(1)
      return true if list_of_possible_moves.include?(king.current_pos)
    end
  end

  def determine_checkmate
    # A checkmate is decided when a king is checked and has no possible moves
    # without going into another check.
  end

  def determine_tie
    # A tie is decided when...
  end
end
