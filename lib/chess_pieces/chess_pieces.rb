# frozen_string_literal: true

# Parent class of the chess pieces. This has all the methods needed to generate
# possible moves for each piece.
class ChessPieces
  attr_reader :name, :color, :current_pos, :possible_moves

  def initialize(name, color, index, white_key, black_key)
    @name = name
    @color = color
    @current_pos = index
    @white_key = white_key
    @black_key = black_key
    @possible_moves = create_possible_moves(@current_pos, @white_key, @black_key)
    @icon = determine_icon
  end

  def update_possible_moves
    @possible_moves = create_possible_moves(@current_pos, @white_key, @black_key)
  end

  def create_possible_moves(current_position, white_key, black_key)
    if @color.match('white')
      possible_moves_helper(white_key, current_position).compact
    else
      possible_moves_helper(black_key, current_position).compact
    end
  end

  def possible_moves_helper(key, current_position)
    key.map do |possible_move|
      pos_row = possible_move[0] + current_position[0]
      pos_col = possible_move[1] + current_position[1]
      next unless pos_row.between?(0, 7) && pos_col.between?(0, 7)

      [pos_row, pos_col]
    end
  end

  def update_current_pos(destination)
    @current_pos = destination
  end

  def determine_icon(black, white)
    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end

  def display_icon
    @icon
  end
end
