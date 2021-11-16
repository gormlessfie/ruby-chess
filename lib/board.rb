# frozen_string_literal: true

require './lib/chess_pieces/pawn'
require './lib/chess_pieces/bishop'
require './lib/chess_pieces/king'
require './lib/chess_pieces/queen'
require './lib/chess_pieces/knight'
require './lib/chess_pieces/rook'
require './lib/space'

# A chess board. This is an array of 8 arrays which contains Space objects.
class Board
  def initialize
    @board = setup_board
  end

  private

  def setup_board
    add_pieces(color_board(create_board))
  end

  def create_board
    Array.new(8) { Array.new(8) { Space.new } }
  end

  def color_board(board)
    board.each_with_index do |row, ridx|
      row.each_with_index do |space, sidx|
        space.make_color_black if ridx.even? && sidx.odd?
        space.make_color_black if ridx.odd? && sidx.even?
      end
    end
  end

  def add_pieces(board)
    add_board_elites(0, 'black', board)
    add_board_elites(7, 'white', board)
    add_board_pawns(1, 'black', board)
    add_board_pawns(6, 'white', board)
  end

  def add_board_elites(row, color, board)
    board[row][0].piece = Rook.new(color.to_s)
    board[row][1].piece = Knight.new(color.to_s)
    board[row][2].piece = Bishop.new(color.to_s)
    board[row][3].piece = Queen.new(color.to_s)
    board[row][4].piece = King.new(color.to_s)
    board[row][5].piece = Bishop.new(color.to_s)
    board[row][6].piece = Knight.new(color.to_s)
    board[row][7].piece = Rook.new(color.to_s)

    board
  end

  def add_board_pawns(row, color, board)
    board[row].each do |space|
      space.piece = Pawn.new(color.to_s)
    end

    board
  end
end
