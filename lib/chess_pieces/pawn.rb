# frozen_string_literal: true

class Pawn
  def initialize(color)
    @name = 'pawn'
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
    white_pawn = "\u2659"
    black_pawn = "\u265F"

    @color == 'white' ? white_pawn.encode('utf-8') : black_pawn.encode('utf-8')
  end
end

pe = Pawn.new('black')
puts pe.instance_variable_get(:@icon)
