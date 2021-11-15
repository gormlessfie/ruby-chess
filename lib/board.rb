# frozen_string_literal: true

class Board
  def initialize
    @board = initialize_board
  end

  def initialize_board
    board = Array.new(8) { Array.new(8) }

    board[0] = [Rook.new, Knight.new, Bishop.new, Queen.new,
                King.new, Bishop.new, Knight.new, Rook.new]
    board[1] = [Pawn.new, Pawn.new, Pawn.new, Pawn.new,
                Pawn.new, Pawn.new, Pawn.new, Pawn.new]

    board[0] = [Rook.new, Knight.new, Bishop.new, Queen.new,
                King.new, Bishop.new, Knight.new, Rook.new]
    board[7] = [Rook.new, Knight.new, Bishop.new, Queen.new,
                King.new, Bishop.new, Knight.new, Rook.new]
  end
end

b = Board.new

te = b.instance_variable_get(:@board)
te.each do |row|
  p row
end
