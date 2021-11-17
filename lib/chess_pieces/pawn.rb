# frozen_string_literal: true

class Pawn
  def initialize(color, index)
    @name = 'pawn'
    @color = color
    @current_pos = index
    @white_key = [[-1, 0], [-2, 0]]
    @black_key = [[1, 0], [2, 0]]
    @possible_moves = create_possible_moves(@current_pos, @white_key, @black_key)
    @icon = determine_icon
    @first_turn = true
  end

  def update_possible_moves
    @possibles_moves = create_possible_moves(@current_pos, @white_key, @black_key)
  end

  def create_possible_moves(current_position, white_key, black_key)
    if @color.match('white')
      possible_moves_helper(white_key, current_position)
    else
      possible_moves_helper(black_key, current_position)
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

    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end

  def display_icon
    @icon
  end
end

paw = Pawn.new('black', [1, 3])

p paw.instance_variable_get(:@possible_moves)
