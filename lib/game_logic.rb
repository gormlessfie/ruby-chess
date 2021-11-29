# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
# This object should be created and ran before player chooses piece to move.
class GameLogic
  def initialize(board)
    @logic_board = board
    @list_of_white_pieces = @logic_board.get_list_of_pieces('white')
    @list_of_black_pieces = @logic_board.get_list_of_pieces('black')
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

  def determine_stalemate(valid_list, king)
    return if king.check

    return true if valid_list.empty?

    # A stalemate is decided when...
    # 1 King is not in check
    # 2 No pieces that won't cause a self-check
    list_pieces = valid_list.map { |valid_piece| true if valid_piece.possible_moves.empty? }
    return true if list_pieces.all?(true) && king.possible_moves.empty

    false
  end

  # There are 3 types of draws that can occur:

  # 3 Rep rule: If the same board occurs three times, then a draw is called
  # Keep a snapshot of what the board is like with an array by pushing each space into the array.
  # If there are three sub-arrays that are identical in the array, then 3 rep rule is called.

  # 50 turn rule: If 50 turns has passed without no captures made and no pawns moved. A draw is called.
  # Keep a count of the moves performed in total, if the last 50 does not contain a pawn move.
  # Reset counter if the length of the number of pieces decrease.

  # Insufficent materials: If the players do not have enough pieces to perform a checkmate, a draw is called.
  # King Knight vs King | King vs King | King Bishop vs King | King Bishop same space color vs King Bishop same space color
  # Check the pieces_list of each player and see if they match any of these combinations.
  # Must check for both sides, ie King Knight vs King && King vs King Knight
  def determine_draw_turns(turns)
    num_pieces = @logic_board.find_all_pieces.length

    false
  end

  def determine_draw_king_king
    white_list = @list_of_white_pieces
    black_list = @list_of_black_pieces
    return true if only_piece_king(white_list) && only_piece_king(black_list)

    false
  end

  def determine_draw_king_bishop
    white_list = @list_of_white_pieces
    black_list = @list_of_black_pieces

    if (only_piece_king_bishop(white_list) && only_piece_king(white_list)) ||
       (only_piece_king_bishop(black_list) && only_piece_king(black_list))
      return true
    end

    false
  end

  def only_piece_king(list)
    return true if list.length == 1 && list[0].name == 'king'

    false
  end

  def only_piece_king_bishop(list)
    return true if list.length == 2 && list[0].name == 'king' && list[1].name == 'bishop'

    false
  end
end
