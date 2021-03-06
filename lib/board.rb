# frozen_string_literal: true

require './lib/chess_pieces/pawn'
require './lib/chess_pieces/bishop'
require './lib/chess_pieces/king'
require './lib/chess_pieces/queen'
require './lib/chess_pieces/knight'
require './lib/chess_pieces/rook'
require './lib/space'
require 'colorize'

# The chess board. This is an array which has 8 arrays of Space Objects.
class Board
  attr_accessor :board

  def initialize
    @board = setup_board
  end

  def get_list_pawns(color)
    get_list_of_pieces(color).select do |piece|
      piece.name == 'pawn' && piece.color == color
    end
  end

  def get_list_of_pieces(color)
    list = []
    @board.each do |row|
      row.each do |space|
        list.push(space.piece) if space&.piece&.color == color
      end
    end
    list
  end

  def get_opponent_list_pieces(color)
    color == 'white' ? get_list_of_pieces('black') : get_list_of_pieces('white')
  end

  def find_all_pieces
    get_list_of_pieces('white').concat(get_list_of_pieces('black'))
  end

  def get_king(color)
    king = get_list_of_pieces(color).select { |piece| piece.name.match('king') }
    king[0]
  end

  def get_rook(color, which_rook)
    pieces_list = get_list_of_pieces(color)
    rook_list = pieces_list.select { |piece| piece.name == 'rook' }

    which_rook == 'left' ? rook_list[0] : rook_list[1]
  end

  def display_board
    print '         '
    puts ' 0  1  2  3  4  5  6  7 '
    @board.each_with_index do |row, ridx|
      print "       #{ridx} "
      row.each do |space|
        space.color == 'white' ? print_space_color(space, :blue) : print_space_color(space, :black)

        # print "[#{space.piece.display_icon}]" unless space.piece.nil?

        # print '[ ]' if space.piece.nil?
      end
      puts "\n"
    end
  end

  def print_space_color(space, color)
    # The background color is white
    print " #{space.piece.display_icon} ".colorize(background: color) unless space.piece.nil?

    print '   '.colorize(background: color) if space.piece.nil?
  end

  def move_piece(initial_pos, dest_pos)
    chess_piece = @board[initial_pos[0]][initial_pos[1]].piece
    @board[dest_pos[0]][dest_pos[1]].piece = chess_piece
  end

  def make_space_empty(position)
    @board[position[0]][position[1]].piece = nil
  end

  def promote_pawn(choice, position)
    space = @board[position[0]][position[1]]
    color = space.piece.color

    space.piece = case choice
                  when 'queen'
                    Queen.new(color, position)
                  when 'rook'
                    Rook.new(color, position)
                  when 'bishop'
                    Bishop.new(color, position)
                  else
                    Knight.new(color, position)
                  end
  end

  def attacking_piece(player, king)
    # Get the attacking piece.
    enemy_list = get_list_of_pieces(player.opponent_color)

    enemy_list.select do |piece|
      piece.possible_moves.flatten(1).include?(king.current_pos)
    end
  end

  def attacking_piece_directional_list(attacking_piece, king)
    attacking_piece.possible_moves.select do |directional_list|
      directional_list.include?(king.current_pos)
    end
  end

  def deep_copy
    Marshal.load(Marshal.dump(@board))
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
    board[row][0].piece = Rook.new(color.to_s, [row, 0])
    board[row][1].piece = Knight.new(color.to_s, [row, 1])
    board[row][2].piece = Bishop.new(color.to_s, [row, 2])
    board[row][3].piece = Queen.new(color.to_s, [row, 3])
    board[row][4].piece = King.new(color.to_s, [row, 4])
    board[row][5].piece = Bishop.new(color.to_s, [row, 5])
    board[row][6].piece = Knight.new(color.to_s, [row, 6])
    board[row][7].piece = Rook.new(color.to_s, [row, 7])

    board
  end

  def add_board_pawns(row, color, board)
    board[row].each_with_index do |space, sidx|
      space.piece = Pawn.new(color.to_s, [row, sidx])
    end

    board
  end
end
