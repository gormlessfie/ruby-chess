# frozen_string_literal: true

class Queen
  def initialize(color)
    @name = 'queen'
    @color = color
    @current_pos = find_pos
    @possible_moves = update_possible_moves
    @icon = determine_icon
  end

  def find_pos
  end

  def update_possible_moves
  end

  def determine_icon
    black = "\u2655"
    white = "\u265B"

    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end

  def display_icon
    @icon
  end
end
