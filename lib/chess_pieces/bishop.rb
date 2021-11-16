# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

class Bishop
  def initialize(color)
    @name = 'bishop'
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
    black = "\u2657"
    white = "\u265D"

    @color == 'white' ? white.encode('utf-8') : black.encode('utf-8')
  end

  def display_icon
    @icon
  end
end
