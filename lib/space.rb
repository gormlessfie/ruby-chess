# frozen_string_literal: true

# A square in the board.
class Space
  attr_accessor :piece

  def initialize(color = 'white', piece = nil)
    @color = color
    @piece = piece
  end

  def make_color_black
    @color = 'black'
  end
end
