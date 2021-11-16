# frozen_string_literal: true

class Knight
  def initialize(color)
    @name = 'knight'
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
    white = "\u2658"
    black = "\u265E"

    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end

  def display_icon
    @icon
  end
end
