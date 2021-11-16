# frozen_string_literal: true

# A square in the board.
class Space
  attr_accessor :present_piece

  def initialize(color = 'white', piece = nil)
    @color = color
    @present_piece = piece
  end

  def make_color_black
    @color = 'black'
  end
end
