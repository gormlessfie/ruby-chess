# frozen_string_literal: true

# This checks if the board is in a state where a winner can be declared.
# This object should be created and ran before player chooses piece to move.
class GameLogic
  @@previous_boards = []
  @@prev_pawn_pos = nil
  @@prev_num_pieces = nil

  def initialize(board)
    @logic_board = board
    @list_of_white_pieces = @logic_board.get_list_of_pieces('white')
    @list_of_black_pieces = @logic_board.get_list_of_pieces('black')

    @board_num_pieces = update_board_num_pieces
    @board_pawn_pos = pawn_pos

    @@prev_num_pieces = @board_num_pieces if @@prev_num_pieces.nil?
    @@prev_pawn_pos = @board_pawn_pos if @@prev_pawn_pos.nil?
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
    return false if king.check

    return true if valid_list.empty?

    # A stalemate is decided when...
    # 1 King is not in check
    # 2 No pieces that won't cause a self-check
    list_pieces = valid_list.map { |valid_piece| true if valid_piece.possible_moves.empty? }
    return true if list_pieces.all?(true) && king.possible_moves.empty?

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
  def add_to_history
    current_board = []

    @logic_board.board.each do |row|
      row.each do |space|
        current_board.push([space.piece&.name, space.piece&.color])
      end
    end

    @@previous_boards.push(current_board)
  end

  def reset_turn_counter
    true
  end

  def determine_fifty_turns(turn_counter)
    reset_turn_counter if pawn_moved || made_capture

    return true if turn_counter == 50

    # If fifty turns has passed and no captures made, no pawns moved, draw.
    #  Keep track of the number of pieces on the board.
    #  Keep track of pawn positions.
    # Only check this draw condition every fifty turns. ie turn counter 50
    false
  end

  def pawn_moved
    if @board_pawn_pos != @@prev_pawn_pos
      update_prev_pawn_pos
      true
    else
      false
    end
  end

  def made_capture
    if @board_num_pieces < @@prev_num_pieces
      update_prev_num_pieces
      true
    else
      false
    end
  end

  def pawn_pos
    @logic_board
      .get_list_pawns('white')
      .concat(@logic_board.get_list_pawns('black'))
      .map(&:current_pos)
  end

  def update_prev_pawn_pos
    @@prev_pawn_pos = @board_pawn_pos
  end

  def update_prev_num_pieces
    @@prev_num_pieces = @board_num_pieces
  end

  def update_board_num_pieces
    @board_num_pieces = @list_of_white_pieces
                        .concat(@list_of_black_pieces).length
  end

  def determine_three_rep_rule
    # If there are three occurrences of the same element, then true
    tally = @@previous_boards.tally.map { |_k, v| v }

    return true if tally.select { |occurrences| occurrences > 2 }.length.positive?

    false
  end

  def determine_draw_king_knight
    determine_draw_two_pieces(King, Knight)
  end

  def determine_draw_king_bishop
    determine_draw_two_pieces('king', 'bishop')
  end

  def determine_draw_same_color_king_bishop
    determine_draw_two_pieces('king', 'bishop') &&
      determine_same_space_color_bishops
  end

  def determine_same_space_color_bishops
    # if bishops on same color, then draw

    white_bishop = @list_of_white_pieces.select { |piece| piece.is_a?(Bishop) }
    black_bishop = @list_of_black_pieces.select { |piece| piece.is_a?(Bishop) }

    color_space_white_bishop = @logic_board.board[white_bishop.current_pos[0]][white_bishop.current_pos[1]]
                                           .color
    color_space_black_bishop = @logic_board.board[black_bishop.current_pos[0]][black_bishop.current_pos[1]]
                                           .color

    return true if color_space_white_bishop == color_space_black_bishop

    false
  end

  def determine_draw_king_king
    white_list = @list_of_white_pieces
    black_list = @list_of_black_pieces
    return true if only_piece_king(white_list) && only_piece_king(black_list)

    false
  end

  def determine_draw_two_pieces(piece_one, piece_two)
    white_list = @list_of_white_pieces
    black_list = @list_of_black_pieces

    if (only_two_pieces(piece_one, piece_two, white_list) && only_piece_king(black_list)) ||
       (only_two_pieces(piece_one, piece_two, black_list) && only_piece_king(white_list))
      return true
    end

    false
  end

  def only_piece_king(list)
    return true if list.length == 1 && list.select { |p| p.name == 'king' }[0]

    false
  end

  def only_two_pieces(piece_one, piece_two, list)
    in_list = list.select { |p| p.name == piece_one || p.name == piece_two }
    return true if in_list.length == 2

    false
  end

  def show_history
    @@previous_boards
  end
end
