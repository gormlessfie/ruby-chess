# frozen_string_literal: true

require './lib/chess_pieces/pawn'
require './lib/chess_pieces/bishop'
require './lib/chess_pieces/king'
require './lib/chess_pieces/queen'
require './lib/chess_pieces/knight'
require './lib/chess_pieces/rook'


class Board
  def initialize
    @board = initialize_board
  end

  def initialize_board
    board = Array.new(8) { Array.new(8) }

    board[0] = [Rook.new('black'), Knight.new('black'), Bishop.new('black'),
                Queen.new('black'), King.new('black'), Bishop.new('black'),
                Knight.new('black'), Rook.new('black')]
    board[1] = Array.new(8) { Pawn.new('black') }

    board[6] = Array.new(7) { Pawn.new('white') }
    board[7] = [Rook.new('white'), Knight.new('white'), Bishop.new('white'),
                Queen.new('white'), King.new('white'), Bishop.new('white'),
                Knight.new('white'), Rook.new('white')]

    board
  end
end

b = Board.new

te = b.instance_variable_get(:@board)
te.each do |row|
  puts row
end
