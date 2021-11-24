# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
# This object should be created and ran before player chooses piece to move.
class GameLogic
  def initialize(board)
    @chess_board = board
    @list_of_white_pieces = @chess_board.get_list_of_pieces('white')
    @list_of_black_pieces = @chess_board.get_list_of_pieces('black')
  end

  def king_in_check?(king)
    enemy_list = king.color == 'white' ? @list_of_black_pieces : @list_of_white_pieces

    enemy_list.each do |opponent_piece|
      list_of_possible_moves = opponent_piece.possible_moves.flatten(1)
      return true if list_of_possible_moves.include?(king.current_pos)
    end
    false
  end

  def checkmate?(king)
    # A checkmate is decided when a king is checked and has no possible moves
    # from any piece without going into another check.
    return true if king_in_check?(king)

    false
  end

  def determine_tie
    # A tie is decided when...
  end
end
