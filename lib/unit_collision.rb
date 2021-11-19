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

    possible_move_list.each do |list_possible_space|
      possible_space = list_possible_space[0]

      next unless piece_in_space_exist?(possible_space)

      pot_piece = @collision_board.board[possible_space[0]][possible_space[1]].piece
      problem_spaces.push(possible_space) if pieces_same_color?(moving_piece, pot_piece)
    end

    problem_spaces
  end

  def piece_in_space_exist?(index)
    return true unless @collision_board.board[index[0]][index[1]].piece.nil?

    false
  end

  def pieces_same_color?(piece_one, piece_two)
    piece_one.color == piece_two.color
  end
end

