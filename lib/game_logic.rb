# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
# This object should be created and ran before player chooses piece to move.
class GameLogic
  def initialize(board)
    @chess_board = board
    @list_of_white_pieces = @chess_board.get_list_of_pieces('white')
    @list_of_black_pieces = @chess_board.get_list_of_pieces('black')
  end

  def king_in_check?(king_color)
    enemy_list = nil
    king = nil

    if king_color.match('white')
      enemy_list = @list_of_black_pieces
      king = @list_of_white_pieces.select { |piece| piece.name.match('king') }[0]
    else
      enemy_list = @list_of_white_pieces
      king = @list_of_black_pieces.select { |piece| piece.name.match('king') }[0]
    end

    enemy_list.each do |opponent_piece|
      list_of_possible_moves = opponent_piece.possible_moves.flatten(1)
      return true if list_of_possible_moves.include?(king.current_pos)
    end

    false
  end

  def determine_checkmate
    # A checkmate is decided when a king is checked and has no possible moves
    # without going into another check.

    # Check player's king to see if it is in @check

    # Check the king's possible moves.

    # If king has no possible moves, then checkmate is declared
    
    # 
  end

  def determine_tie
    # A tie is decided when...
  end
end
