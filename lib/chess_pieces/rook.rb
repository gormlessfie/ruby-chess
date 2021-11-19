# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'
require 'pry-byebug'

# A rook chess piece. Moves vertically or horizontally, no limit. Can be blocked. 
class Rook < ChessPieces
  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('rook', color, index, white_key, black_key)
  end

  def create_key
    [[-1, 0], [1, 0], [0, -1], [0, 1]]
  end

  def determine_icon
    black = "\u2656"
    white = "\u265C"
    super(black, white)
  end

  def possible_moves_helper(key, current_position)
    complete_list = []
    row = current_position[0]
    col = current_position[1]

    key.each do |index|
      complete_list.concat(multiple_spaces_helper(index, [row, col]))
    end
    complete_list
  end

  def multiple_spaces_helper(key, cur_pos)
    possible_moves_list = []

    while cur_pos[0].between?(0, 7) && cur_pos[1].between?(0, 7)
      cur_pos[0] -= key[0]
      cur_pos[1] -= key[1]

      return possible_moves_list unless cur_pos[0].between?(0, 7) &&
                                        cur_pos[1].between?(0, 7)

      possible_moves_list.push([cur_pos[0], cur_pos[1]])
    end

    possible_moves_list
  end
end
