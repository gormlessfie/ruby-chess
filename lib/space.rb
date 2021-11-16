# frozen_string_literal: true

# A square in the board.
class Space
  def initialize(color = white, piece = nil)
    @color = color
    @present_piece = piece
  end
end
