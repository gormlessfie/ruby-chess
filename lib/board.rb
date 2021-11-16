# frozen_string_literal: true

require './lib/chess_pieces/pawn'
require './lib/chess_pieces/bishop'
require './lib/chess_pieces/king'
require './lib/chess_pieces/queen'
require './lib/chess_pieces/knight'
require './lib/chess_pieces/rook'
require './lib/space'

class Board
  def initialize
    @board = setup_board
  end

  def setup_board
    color_board(create_board)
  end

  def create_board
    Array.new(8) { Array.new(8) { Space.new } }
  end

  def color_board(board = @board)
    board.each_with_index do |row, ridx|
      row.each_with_index do |space, sidx|
        space.make_color_black if ridx.even? && sidx.odd?
        space.make_color_black if ridx.odd? && sidx.even?
      end
    end
  end

end

b = Board.new

board = b.instance_variable_get(:@board)
board.each { |row| p row }

