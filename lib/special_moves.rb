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
    return false if player_rook.nil?

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
    return false if enemy_moves.include?(one_space) || enemy_moves.include?(two_space)

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

  # Pawns should have an en_passant variable which becomes true if the pawn did
  # a 2 square move. (The leap on the first turn)

  # Pawns with a true en_passant variable are able to get eaten by pawns to the
  # left or right of its current position

  # When the en_passant variable is true and there are pawns to the left or right
  # Then update the pawn to the left or right with the en_passant possible move
  # The attacking pawn will move to the pawn's current rank position - 1

  def find_en_passant_recip
    @special_board.get_list_pawns(@player.color).select(&:en_passant_recip)[0]
  end

  def find_en_passant_recip_enemy
    @special_board.get_list_pawns(@player.opponent_color).select(&:en_passant_recip)[0]
  end

  def find_en_passant_pieces
    @special_board.get_list_pawns(@player.color).select(&:en_passant)
  end

  def adj_piece_en_passant_recip(en_passant_pawn, side)
    pos = en_passant_pawn.current_pos
    adj_pos = pos[1] + side

    return nil unless adj_pos.between?(0, 7)

    @special_board.board[pos[0]][pos[1] + side].piece
  end

  def add_en_passant_attack_move(en_passant_recip, chosen_piece)
    p en_passant_recip
    # adjust for differnt pawn color
    position = en_passant_recip.current_pos
    dest = en_passant_attack_move_pos(en_passant_recip, position)
    chosen_piece&.add_possible_attack_spaces([[[dest]]])
  end

  def en_passant_attack_move_pos(en_passant_recip, position)
    en_passant_recip.color == 'white' ? [position[0] + 1, position[1]] : [position[0] - 1, position[1]]
  end

  # Pawn Promotion
  # When a pawn reaches the opposite rank (row), white: row 0 ; black: row 7
  # The pawn will promote to any piece the player decides.
  def update_pawn_promotion_status
    list_pawns = @special_board.get_list_pawns(@player.color)
    list_pawns.each { |pawn| pawn.update_pawn_promotion if pawn.current_pos[0].zero? || pawn.current_pos[0] == 7 }
  end
end
