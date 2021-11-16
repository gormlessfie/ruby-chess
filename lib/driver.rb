# frozen_string_literal: true

require './lib/game'

game = Game.new

board = game.instance_variable_get(:@chess_board).instance_variable_get(:@board)
p board[0]
