# frozen_string_literal: true

# A square in the board. The space object has the color of the space and
# the piece it is holding, if any.
class Space
  attr_reader :color
  attr_accessor :piece

  def initialize(color = 'white', piece = nil)
    @color = color
    @piece = piece
  end

  def make_color_black
    @color = 'black'
  end
end
