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
      player_turn(@white_player)
      player_turn(@black_player)
      choose_winner(@white_player)
    end
  end

  def player_turn(player)
    # pick a space. (piece to move)
    chosen_space = player.player_input
    # Generate possibles moves of that piece in that space
    chosen_row = chosen_space[0]
    chosen_col = chosen_space[1]

    piece = @chess_board.board[chosen_row][chosen_col].piece
    p piece

    # Display which piece has been chosen
    puts "You have chosen #{piece.color} #{piece.name} at #{piece.current_pos}."

    # print all possible moves that the player can do.
    puts "Please choose from these possible moves: #{piece.possible_moves}"

    # get another player input (player, destination)
    chosen_destination = player.player_input

    # Move piece to designated space.
    # update current_pos of the piece
    # Make origin space empty.
  end

  def game_start
    intro_message
    @chess_board.display_board
    game_round
    game_end_message(@winner)
  end

  def choose_winner(player)
    @winner = player
  end

  def intro_message
    puts %(
      This is the game of Chess.

      White will go first and then black. Each player must move a piece even if
      it will be detrimental.

      Input a string such as '3,4' to select a piece to move. You cannot
      switch once selected.

      Input another array to select the destination. '4,4'

    )
  end

  def game_end_message(winner)
    puts %(
      #{winner.color} has won!
    )
  end
end
