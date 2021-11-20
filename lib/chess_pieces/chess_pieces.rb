# frozen_string_literal: true

require 'pry-byebug'

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

  def create_key
    # The key is in the order: middle-left, top-left, top, top-right, right,
    # bottom-right, bottom, bottom-left,
  end

  def remove_possible_spaces_where_conflict(list)
    # This removes the possible_moves where the piece can't go because of blocking.
    # List contains closest space to the chosen_piece that is blocked.
    list.each do |problem_space|
      @possible_moves.each_with_index do |list_possible, list_idx|
        list_possible.each do |possible_space|
          if possible_space == problem_space
            index = list_possible.index(possible_space)
            @possible_moves[list_idx] = @possible_moves[list_idx].slice(0, index)
          end
        end
      end
    end
  end

  def add_possible_attack_spaces(list)
    # The list should be an array of nested arrays that may be empty.
    # i.e. [[], [], [[1, 3]], []]
    list.each_with_index do |attack_space, idx|
      @possible_moves[idx].push(attack_space.flatten(1)) unless attack_space.empty?
    end
  end

  def remove_empty_direction_possible_moves
    @possible_moves.delete_if(&:empty?)
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

      [[pos_row, pos_col]]
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
