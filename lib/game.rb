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
      @chess_board.display_board
      player_turn(@black_player)
      choose_winner(@white_player)
    end
  end

  def player_turn(player)
    # pick a space. (piece to move)
    chosen_piece = nil
    loop do
      chosen_coords = player.player_input('select')

      # Generate possibles moves of that piece in that space
      chosen_space = @chess_board.board[chosen_coords[0]][chosen_coords[1]]
      if chosen_space.piece && chosen_space.piece.color == player.color
        chosen_piece = chosen_space.piece
        break
      elsif chosen_space.piece.nil?
        print '       '
        puts "You have selected #{chosen_coords} which contains no chess piece."
      else
        print '       '
        puts "You have selected #{chosen_coords} which is a piece not of your color."
        print '       '
        puts 'Please choose a piece of your color'
      end
    end

    # Display which piece has been chosen
    print '       '
    puts "You have chosen #{chosen_piece.color} #{chosen_piece.name} at " \
         "#{chosen_piece.current_pos}."

    # display board
    @chess_board.display_board

    # print all possible moves that the player can do.
    print '       '
    puts "Please choose from these possible moves: #{chosen_piece.possible_moves}"

    # get another player input (player, destination)
    loop do
      chosen_destination = player.player_input('destination')

      break if chosen_piece.possible_moves.include?(chosen_destination)

      # check if input is within possible moves for that piece
      print '       '
      puts "#{chosen_destination} is not a possible move."
    end
    # Move piece to designated space.

    # update current_pos of the piece

    # update possible moves of the piece

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
