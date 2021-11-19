# frozen_string_literal: true

# This object takes in the board and checks for collisions.
class UnitCollision
  def initialize(board)
    @collision_board = board
  end
  
  def provide_problem_spaces_same_color
  end

  def piece_in_space_exist?(index)
    return true unless @collision_board[index[0]][index[1]].piece.nil?

    false
  end

  def piece_in_space_same_color?(chosen_piece, index)
    index_piece = @collision_board[chosen_piece[0]][chosen_piece[1]]
    possible_piece = @collision_board[index[0]][index[1]]
    return true if pieces_same_color?(index_piece, possible_piece)

    false
  end

  def pieces_same_color?(piece_one, piece_two)
    piece_one.color == piece_two.color
  end
end
