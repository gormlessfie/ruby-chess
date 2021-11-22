# frozen_string_literal: true

require './lib/board'
require './lib/player'
require './lib/game_logic'
require './lib/unit_collision'

require 'pry-byebug'

# This holds all the methods that runs the game such as turns.
class Game
  def initialize
    @chess_board = Board.new
    @white_player = Player.new('white')
    @black_player = Player.new('black')
    @winner = nil
    @turn_counter = 0
  end

  def game_round
    while @winner.nil?
      player_turn(@white_player) if @winner.nil?
      player_turn(@black_player) if @winner.nil?
      increment_turn_counter if @winner.nil?
    end
  end

  def player_turn(player)
    # Update all pieces at the start of every turn
    update_all_pieces(@chess_board.find_all_pieces)

    # Create game_logic with current board
    game_logic = GameLogic.new(@chess_board)
    player_king = @chess_board.get_king(player.color)

    # Check & update player king check
    update_king_check_condition(game_logic, player_king)

    # Check board for checkmate condition
    game_logic.checkmate?(player_king)
    # Check board for tie condition
    game_logic.determine_tie

    # display board
    print_board

    # If player is checked, must either move king or a piece that stops the check.
    # A piece that stops the check is one that makes the space the king is on no longer
    # possible.
    # The piece should be able to eat the attacking piece, or move to a space
    # that is within the list of possible move space that blocks movement to
    # the king.

    if game_logic.king_in_check?(player_king)
      # Find the attacking piece

      # Find the list of pieces that can stop the check
      list_valid_pieces = find_valid_pieces_stop_check(player, player_king)
        # The list should contain the player's color pieces that can move to the
        # attacking piece's possible spaces or on the attack piece space.

      # pick a piece that can stop the check.
      chosen_piece = nil
      loop do
        chosen_piece = setup_piece(player)

        break if list_valid_pieces.include?(chosen_piece)

        print '       '
        puts 'You must choose a piece that can stop the check'
        list_valid_pieces.each do |piece|
          puts "The valid pieces are: #{piece.name} at #{piece.current_pos}"
        end
      end
      chosen_initial = chosen_piece.current_pos

      # clear
      #clear_console

      # Display which piece has been chosen
      print_check_king_message
    else
      # pick a piece to move.
      chosen_piece = setup_piece(player)
      chosen_initial = chosen_piece.current_pos

      # clear
      clear_console

      # Display which piece has been chosen
      print_chosen_piece(chosen_piece)
    end

    # display board
    print_board

    # print all possible moves that the player can do.
    print_possible_moves_piece(chosen_piece)

    # get another player input (player, destination)
    chosen_destination = choose_destination(player, chosen_piece)

    # clear
    #clear_console

    # move piece, update old spot, update current pos, update new moves
    move_piece_complete(chosen_piece, chosen_initial, chosen_destination)
  end

  def setup_piece(player)
    loop do
      chosen_initial = player.player_input('select')
      chosen_space = @chess_board.board[chosen_initial[0]][chosen_initial[1]]

      return chosen_space.piece if chosen_space.piece &&
                                   chosen_space.piece.color == player.color &&
                                   !chosen_space.piece.possible_moves.empty?

      error_message_invalid_space(chosen_space, chosen_initial)
    end
  end

  def update_piece_with_object_collision(chosen_piece)
    # Create UnitCollision object
    collision = UnitCollision.new(@chess_board)

    # Provide a list of any blocking pieces for the chosen_piece.
    blocking_pieces = collision.provide_problem_spaces_same_color(chosen_piece)
    attack_pieces = collision.provide_attack_spaces(chosen_piece)

    # Remove all spaces at and beyond the blocking piece.
    chosen_piece.remove_possible_spaces_where_conflict(blocking_pieces)
    chosen_piece.add_possible_attack_spaces(attack_pieces)
    chosen_piece.remove_empty_direction_possible_moves
  end

  def find_valid_pieces_stop_check(player, king)
    # A valid piece is a piece with a possible moves list that can eat the
    # attacking piece or move into the possible moves list of the attacking piece
    # The king is also a valid piece, given that the king has possible moves.

    valid_pieces = []
    valid_pieces.push(king)
    # Get the list of the player's pieces
    list_player_pieces = @chess_board.get_list_of_pieces(player.color)

    # Get the attacking piece.
    enemy_list = @chess_board.get_list_of_pieces(player.opponent_color)

    attacking_piece = enemy_list.select do |piece|
      piece.possible_moves.include?([king.current_pos])
    end

    attacking_piece = attacking_piece[0]

    list_player_pieces.each do |piece|
      next if piece.possible_moves.empty?

      if attacking_piece.possible_moves.intersection(piece.possible_moves).length.positive? ||
         piece.possible_moves.include?([attacking_piece.current_pos])
        valid_pieces.push(piece)
      end
    end
    # The attacking piece is the piece with the possible_moves list that can move on the king.
    # A piece is added to the valid list if the piece's possible_moves list has
    # the attacking_piece current_pos or a possible_move that is the same as
    # the attacking_piece possible_move.

    # if attacking_piece.possible_moves includes the space of 

    valid_pieces
  end

  def choose_destination(player, chosen_piece)
    loop do
      destination = player.player_input('destination')

      return destination if chosen_piece.possible_moves.flatten(1).include?(destination)

      # check if input is within possible moves for that piece

      clear_console
      print_board
      puts "\n"

      print '       '
      puts "#{destination} is not a possible move."
      print_possible_moves_piece(chosen_piece)
    end
  end

  def move_piece_complete(piece, initial, destination)
    # Move piece to designated space.
    @chess_board.move_piece(initial, destination)

    # update pawn, king, or rook first turn if moved
    update_piece_first_turn(piece)

    # Make origin space empty.
    @chess_board.make_space_empty(initial)

    # update current_pos of the piece
    piece.update_current_pos(destination)
  end

  def update_piece_first_turn(piece)
    piece.update_first_turn_false if piece.name.match('pawn') &&
                                     piece.first_turn

    piece.update_first_turn_false if piece.name.match('king') &&
                                     piece.first_turn

    piece.update_first_turn_false if piece.name.match('rook') &&
                                     piece.first_turn
  end

  def update_piece_moves(chosen_piece)
    chosen_piece&.update_possible_moves
    update_piece_with_object_collision(chosen_piece) if chosen_piece

    if chosen_piece.name.match('king')
      send_update_king_remove_check_spaces(chosen_piece.color, chosen_piece)
    end
  end

  def update_all_pieces(list_of_pieces)
    list_of_pieces.each { |piece| update_piece_moves(piece) }
  end

  def update_king_check_condition(game_logic, king)
    game_logic.king_in_check?(king) ? king.update_check(true) : king.update_check(false)
  end

  def send_update_king_remove_check_spaces(color, king)
    enemy_list = @chess_board.get_opponent_list_pieces(color)
    array = []
    enemy_list.each do |piece|
      possible_list = piece.possible_moves
      array.concat(possible_list)
    end
    king.remove_possible_spaces_where_check(array)
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

  def print_check_king_message
    print '       '
    puts "You have chosen a #{piece.color} #{piece.name} at " \
         "#{piece.current_pos}. This piece must stop the check."
  end

  def error_message_invalid_space(space, position)
    clear_console
    print_board
    puts "\n"
    print '       '
    if space.piece.nil?
      puts "You have selected #{position} which contains no chess piece."
    elsif space.piece.possible_moves.empty?
      puts "There are no possible spaces for this #{space.piece.color} " \
           "#{space.piece.name} to move to."
    else
      puts "You have selected #{position} which is a piece not of your color."
      print '       '
      puts 'Please choose a piece of your color'
    end
  end

  def clear_console
    system('clear')
    puts "\n\n\n"
  end

  def game_start
    clear_console
    intro_message
    game_round
    game_end_message(@winner)
  end

  def increment_turn_counter
    @turn_counter += 1
  end

  def choose_winner(player)
    @winner = player
  end

  def intro_message
    puts %(
      This is the game of Chess.

      White will go first and then black. Each player must move a piece even if
      it will be detrimental. A tie will be declared when 50 turns are taken.

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
