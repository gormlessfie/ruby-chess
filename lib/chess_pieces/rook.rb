# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A rook chess piece. Moves vertically or horizontally, no limit. Can be blocked.
class Rook < ChessPieces
  attr_reader :first_turn, :castling

  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('rook', color, index, white_key, black_key)
    @first_turn = true
    @castling = true
  end

  def create_key
    [[-1, 0], [0, 1], [1, 0], [0, -1]]
  end

  def determine_icon
    white = "\u2656"
    black = "\u265C"
    super(black, white)
  end

  def possible_moves_helper(key, current_position)
    complete_list = []
    row = current_position[0]
    col = current_position[1]
    key.each do |index|
      list = multiple_spaces_helper(index, [row, col])
      complete_list.push(list) unless list.empty?
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
  end

  def update_first_turn_false
    @first_turn = false
  end

  def update_castling_status_false
    @castling = false
  end
end
