# frozen_string_literal: true

# This object takes in the board and checks for collisions.
class UnitCollision
  def initialize(board)
    @collision_board = board
  end

  # This will check if there are any pieces of the same color on a possible move
  # space of the chosen piece that is going to be moved.
  # This returns an array of the spaces that have the issue.
  # possible_move_list is an array of indexs. i.e [3, 3]
  def provide_problem_spaces_same_color(moving_piece)
    problem_spaces = []
    possible_move_list = moving_piece.possible_moves

    possible_move_list.each do |possible_spaces_list|
      possible_spaces_list.each do |next_space|
        next unless piece_in_space_exist?(next_space)

        problem_spaces.push(next_space)
        break
      end
    end
    problem_spaces
  end

  def provide_attack_spaces(moving_piece)
    # This finds the space where of the opposite color in possible spaces to move.
    attack_spaces = []
    possible_move_list = moving_piece.possible_moves

    possible_move_list.each do |possible_spaces_list|
      direction_list = []
      possible_spaces_list.each do |next_space|
        next unless piece_in_space_exist?(next_space)

        pot_piece = @collision_board.board[next_space[0]][next_space[1]].piece

        if pieces_different_color?(moving_piece, pot_piece)
          if piece_pawn?(moving_piece)
            direction_list.push(calc_pawn_attack_spaces(moving_piece))
            direction_list = direction_list.flatten
          else
            direction_list.push(next_space)
          end
        end
        break
      end
      attack_spaces.push(direction_list)
      if movi
    end
    attack_spaces
  end

  def calc_pawn_attack_spaces(moving_piece)
    left_attack = calc_pawn_attack(moving_piece, 0)
    right_attack = calc_pawn_attack(moving_piece, 1)

    [left_attack, right_attack].compact
  end

  def calc_pawn_attack(moving_piece, space)
    pos = moving_piece.current_pos
    space_pos = [pos[0] + moving_piece.pawn_attack_key[space][0],
                 pos[1] + moving_piece.pawn_attack_key[space][1]]

    return unless space_pos.all? { |value| value.between?(0, 7) }

    pot_piece = @collision_board.board[space_pos[0]][space_pos[1]].piece

    return space_pos if pieces_different_color?(moving_piece, pot_piece)
  end

  def piece_in_space_exist?(index)
    return true unless @collision_board.board[index[0]][index[1]].piece.nil?

    false
  end

  def pieces_different_color?(piece_one, piece_two)
    piece_one.color != piece_two.color
  end

  def piece_pawn?(piece)
    piece.name == 'pawn'
  end
end

