# frozen_string_literal: true

require './lib/board'

# This object will manage all movements done through special moves such as
# Castling, en passant, pawn promotion
class SpecialMoves
  def initialize(board, player, enemy_moves = nil)
    @special_board = board
    @player = player
    @player_pieces = @special_board.get_list_of_pieces(@player.color)
    @enemy_moves = enemy_moves
  end

  # Castling is done with the rook and king piece. King moves two spaces towards
  # The rook being castled. The rook will be on the space the king skipped over.
    # Rook must not have moved x
    # King must not have moved x
    # King is not in check x
    # King must not move over a space that can be attacked by an enemy piece.
    # Squares between the King and the Rook must be empty

  def able_castling(which_rook, player_king)
    player_rook = @special_board.get_rook(@player.color, which_rook)

    if check_castling_requirements?(which_rook, player_king)
      player_king.update_castling_status(true)
      player_rook.update_castling_status(true)
      return true
    end

    false
  end

  def check_castling_requirements?(which_rook, player_king)
    # Get king info
    k_pos = player_king.current_pos

    # Check if King first turn = true
    # Check if Rook first turn = true
    # Check for empty squares between King and the Rook
    # Check if the squares the king is moving over is not a possible_attack_move of any piece.

    return false unless check_king_first_turn_and_check?(player_king) &&
                        check_rook_first_turn?(which_rook) &&
                        check_empty_spaces_castling?(k_pos, which_rook) &&
                        check_spaces_attacked?(k_pos, which_rook, @enemy_moves)

    true
  end

  def check_rook_first_turn?(which_rook)
    player_rook = @special_board.get_rook(@player.color, which_rook)
    return false unless player_rook.first_turn

    true
  end

  def check_king_first_turn_and_check?(player_king)
    return false if player_king.check || !player_king.first_turn

    true
  end

  def check_empty_spaces_castling?(k_pos, which_rook)
    one_space = get_space_castling(k_pos, which_rook, 1)
    two_space = get_space_castling(k_pos, which_rook, 2)

    return false unless one_space.piece.nil? && two_space.piece.nil?

    true
  end

  def check_spaces_attacked?(k_pos, which_rook, enemy_moves)
    if which_rook == 'left'
      one_space = [k_pos[0], k_pos[1] - 1]
      two_space = [k_pos[0], k_pos[1] - 2]
    else
      one_space = [k_pos[0], k_pos[1] + 1]
      two_space = [k_pos[0], k_pos[1] + 2]
    end

    return false if enemy_moves.include?(one_space) && enemy_moves.include?(two_space)

    true
  end

  def get_space_castling(k_pos, which_rook, spaces)
    if which_rook == 'left'
      @special_board.board[k_pos[0]][k_pos[1] - spaces]
    else
      @special_board.board[k_pos[0]][k_pos[1] + spaces]
    end
  end

  def add_castling_spaces_king(which_rook, player_king)
    k_pos = player_king.current_pos
    if which_rook == 'left'
      player_king.possible_moves.push([[k_pos[0], k_pos[1] - 2]])
    else
      player_king.possible_moves.push([[k_pos[0], k_pos[1] + 2]])
    end
  end
  # En passant
  # When a pawn makes a double step from the second row to the fourth row and
  # there is an enemy pawn on the adjacent square
  # The enemy pawn make move diagonally to the square that was passed over by
  # the double stepping pawn, the third row.
  # This move must be done directly after the double step move

  def check_for_en_passant
  end

  # Pawn Promotion
  # When a pawn reaches the opposite rank (row), white: row 0 ; black: row 7
  # The pawn will promote to any piece the player decides.
  def update_pawn_promotion_status
    list_pawns = @special_board.get_list_pawns(@player.color)
    list_pawns.each { |pawn| pawn.update_pawn_promotion if pawn.current_pos[0].zero? || pawn.current_pos[0] == 7 }
  end
end
