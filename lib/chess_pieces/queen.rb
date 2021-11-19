# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A queen chess piece. The queen can move like rook and bishop combined, no limit.
# Can be blocked.
class Queen < ChessPieces
  def initialize(color, index)
    white_key = create_key
    black_key = create_key
    super('queen', color, index, white_key, black_key)
  end

  def create_key
    [[-1, -1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]
  end

  def determine_icon
    black = "\u2655"
    white = "\u265B"

    super(black, white)
  end

  # def possible_moves_helper(key, current_position)
  #   complete_list = []
  #   key.each do |index|
  #     complete_list.concat(multiple_spaces_helper(index, current_position))
  #   end
  #   complete_list
  # end

  # def multiple_spaces_helper(key, cur_pos)
  #   possible_moves_list = []

  #   while cur_pos[0].between?(0, 7) && cur_pos[1].between?(0, 7)
  #     row = cur_pos[0] + key[0]
  #     col = cur_pos[1] + key[1]
  #     possible_moves_list.push([row, col])
  #   end

  #   possible_moves_list
  # end
end
