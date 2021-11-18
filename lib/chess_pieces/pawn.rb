# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A Pawn chess piece. This piece can advance forward 2 spaces on the first move
# and 1 space afterwards. This piece can attack diagonally, if there is a
# black piece 1 space diagonal from it in front.
class Pawn < ChessPieces
  attr_reader :name, :color, :current_pos, :possible_moves, :first_turn

  def initialize(color, index)
    super('pawn', color, index, [[-1, 0], [-2, 0]], [[1, 0], [2, 0]])
    @first_turn = true
  end

  def update_first_turn_false
    @first_turn = false
    update_white_key
    update_black_key
  end

  def update_white_key
    @white_key.pop
  end

  def update_black_key
    @black_key.pop
  end

  def determine_icon
    black = "\u2659"
    white = "\u265F"

    super(black, white)
  end
end

# def update_possible_moves
#   @possible_moves = create_possible_moves(@current_pos, @white_key, @black_key)
# end

# def create_possible_moves(current_position, white_key, black_key)
#   if @color.match('white')
#     possible_moves_helper(white_key, current_position)
#   else
#     possible_moves_helper(black_key, current_position)
#   end
# end

# def possible_moves_helper(key, current_position)
#   key.map do |possible_move|
#     pos_row = possible_move[0] + current_position[0]
#     pos_col = possible_move[1] + current_position[1]
#     next unless pos_row.between?(0, 7) && pos_col.between?(0, 7)

#     [pos_row, pos_col]
#   end
# end

# def update_current_pos(destination)
#   @current_pos = destination
# end

# def determine_icon
#   @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
# end

# def display_icon
#   @icon
# end
