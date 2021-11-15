# frozen_string_literal: true

class Board
  def initialize
    @board = initialize_board
  end

  def initialize_board
    Array.new(8) { Array.new(8) }
  end
end

b = Board.new

p b.instance_variable_get(:@board)
