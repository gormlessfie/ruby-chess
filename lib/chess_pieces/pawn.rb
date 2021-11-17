# frozen_string_literal: true

class Pawn
  def initialize(color, index)
    @name = 'pawn'
    @color = color
    @current_pos = index
    @possible_moves = create_possible_moves(@current_pos)
    @icon = determine_icon
    @first_turn = true
  end

  def update_possible_moves

  end

  def create_possible_moves(index)
    white_key = [[-1, 0], [-2, 0]]
    black_key = [[1, 0], [2, 0]]

    if @color.match('white')
      white_key.map do |possible_move|
        pos_row = possible_move[0] + index[0]
        pos_col = possible_move[1] + index[1]
        next unless pos_row.between?(0, 7) && pos_col.between?(0, 7)

        [pos_row, pos_col]
      end
    else
      black_key.map do |possible_move|
        pos_row = possible_move[0] + index[0]
        pos_col = possible_move[1] + index[1]
        next unless pos_row.between?(0, 7) && pos_col.between?(0, 7)
        
        [pos_row, pos_col]
      end
    end
  end

  def update_first_turn_false
    @first_turn = false
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

paw = Pawn.new('black', [6, 3])

p paw.create_possible_moves([6, 3])
