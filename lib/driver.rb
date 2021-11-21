# frozen_string_literal: true

require './lib/game'

game = Game.new

game.game_start

board = game.instance_variable_get(:@chess_board)

p board.board[0][1].piece.possible_moves
