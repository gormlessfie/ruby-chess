# frozen_string_literal: true

require './lib/board'
require './lib/player'
require './lib/game_logic'
require 'pry-byebug'

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
      # player_turn(@black_player)
    end
  end

  def player_turn(player)
    # display board
    print_board

    # pick a space. (piece to move)
    chosen_piece = choose_space(player)
    chosen_initial = chosen_piece.current_pos

    # Display which piece has been chosen
    print_chosen_piece(chosen_piece)
    # display board
    print_board

    # Update possible moves after object collision detection.
    # Check the board if any pieces are in possible move spaces

    # print all possible moves that the player can do.
    print_possible_moves_piece(chosen_piece)

    # get another player input (player, destination)
    chosen_destination = choose_destination(player, chosen_piece)

    # move piece, update old spot, update current pos, update new moves
    move_piece_complete(chosen_piece, chosen_initial, chosen_destination)
  end

  def choose_space(player)
    loop do
      chosen_initial = player.player_input('select')

      chosen_space = @chess_board.board[chosen_initial[0]][chosen_initial[1]]
      return chosen_space.piece if chosen_space.piece &&
                                   chosen_space.piece.color == player.color

      error_message_invalid_space(chosen_space)
    end
  end

  def choose_destination(player, chosen_piece)
    loop do
      destination = player.player_input('destination')

      return destination if chosen_piece.possible_moves.include?(destination)

      # check if input is within possible moves for that piece
      print '       '
      puts "#{destination} is not a possible move."
    end
  end

  def move_piece_complete(piece, initial, destination)
    # Move piece to designated space.
    @chess_board.move_piece(initial, destination)

    # update pawn first turn if moved
    piece.update_first_turn_false if piece.name.match('pawn') &&
                                     piece.first_turn

    # Make origin space empty.
    @chess_board.make_space_empty(initial)

    # update current_pos of the piece
    piece.update_current_pos(destination)

    # update possible moves of the piece
    piece.update_possible_moves
  end

  def print_chosen_piece(piece)
    print '       '
    puts "You have chosen a #{piece.color} #{piece.name} at " \
         "#{piece.current_pos}."
  end

  def print_possible_moves_piece(piece)
    print '       '
    puts "Please choose from these possible moves: #{piece.possible_moves}"
  end

  def print_board
    @chess_board.display_board
  end

  def error_message_invalid_space(space)
    print '       '
    if space.piece.nil?
      puts "You have selected #{chosen_initial} which contains no chess piece."
    else
      puts "You have selected #{chosen_initial} which is a piece not of your color."
      print '       '
      puts 'Please choose a piece of your color'
    end
  end

  def game_start
    intro_message
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
       #{winner.color.upcase} has won!
    )
  end
end
