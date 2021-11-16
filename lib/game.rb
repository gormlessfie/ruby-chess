# frozen_string_literal: true

require './lib/board'
require './lib/player'
require './lib/game_logic'

# This holds all the methods that runs the game such as turns.
class Game
  def initialize
    @chess_board = Board.new
    @white_player = Player.new('white')
    @black_player = Player.new('black')
    @winner = nil
  end

  def game_round
    while @winner.nil?
      @white_player.player_turn
      @black_player.player_turn
    end
  end

  def game_start
    intro_message
    @chess_board.display_board
  end

  def intro_message
    puts %(
      This is the game of Chess.

      White will go first and then black. Each player must move a piece even if
      it will be detrimental.

      Input a string such as 'a5' to select a piece to move. You cannot
      switch once selected.

      Input another array to select the destination. 'a6'

      (1) Play against a computer.
      (2) Play against another player.
    )
  end
end
