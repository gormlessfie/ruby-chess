# frozen_string_literal: true

require './lib/board'
require './lib/player'
require './lib/game_logic'
require './lib/unit_collision'
require './lib/special_moves'

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
    update_all_pieces(@chess_board, @chess_board.find_all_pieces)

    update_king_possible_spaces_when_attacked(@chess_board, 'white')
    update_king_possible_spaces_when_attacked(@chess_board, 'black')

    # Create game_logic with current board
    game_logic = GameLogic.new(@chess_board)
    player_king = @chess_board.get_king(player.color)

    # Check & update player king check
    update_king_check_condition(game_logic, player_king)

    # Check board for checkmate condition
    if find_valid_pieces_stop_check(@chess_board, player, player_king)&.length&.zero? &&
       game_logic.checkmate?(player_king)
      choose_winner(player.opponent_color)
      return if @winner
    end

    # Check board for tie condition
    game_logic.determine_tie

    # If player is checked, must either move king or a piece that stops the check.
    # A piece that stops the check is one that makes the space the king is on no longer
    # possible.
    # The piece should be able to eat the attacking piece, or move to a space
    # that is within the list of possible move space that blocks movement to
    # the king.
    if game_logic.king_in_check?(player_king)
      simulated_board = simulate_valid_move_when_check(@chess_board, player)
      @chess_board.board = simulated_board.deep_copy
    else
      # Every piece is simulated and updated at the start of every turn.
      check_self_check_player_turn(@chess_board, player)
    end
  end

  def setup_piece(board, player)
    loop do
      chosen_initial = player.player_input('select')
      chosen_space = board.board[chosen_initial[0]][chosen_initial[1]]

      return chosen_space.piece if chosen_space.piece &&
                                   chosen_space.piece.color == player.color &&
                                   !chosen_space.piece.possible_moves.empty?

      error_message_invalid_space(board, chosen_space, chosen_initial)
    end
  end

  def update_piece_with_object_collision(board, chosen_piece)
    # Create UnitCollision object
    collision = UnitCollision.new(board)

    # Provide a list of any blocking pieces for the chosen_piece.
    blocking_pieces = collision.provide_problem_spaces_same_color(chosen_piece)
    attack_pieces = collision.provide_attack_spaces(chosen_piece)

    # Remove all spaces at and beyond the blocking piece.
    chosen_piece.remove_possible_spaces_where_conflict(blocking_pieces)
    chosen_piece.add_possible_attack_spaces(attack_pieces)
    chosen_piece.remove_empty_direction_possible_moves
  end

  def simulate_valid_move_when_check(base_board, player)
    simulated_board = nil
    loop do
      print '       '
      puts 'You must stop the check. Please select a unit that can move to ' \
      'protect your king!'

      # create a new board object to simulate the move
      simulated_board = Board.new
      simulated_board.board = base_board.deep_copy

      # Find valid pieces that can be moved.
      king = simulated_board.get_king(player.color)
      valid_pieces = find_valid_pieces_stop_check(base_board, player, king)

      # Print valid pieces
      print_valid_pieces(valid_pieces)

      # perform the move on the simulated board
      player_move_piece(player, simulated_board)

      # Update the possible moves of the attacking piece.
      update_all_pieces(simulated_board, simulated_board.find_all_pieces)

      # create a new game_logic
      simulated_logic = GameLogic.new(simulated_board)
      simulated_king = simulated_board.get_king(player.color)

      update_king_check_condition(simulated_logic, simulated_king)

      valid_move = simulated_logic.king_in_check?(simulated_king)
      break unless valid_move
    end
    simulated_board
  end

  def find_valid_pieces_stop_check(board, player, king)
    # A valid piece is a piece with a possible moves list that can eat the
    # attacking piece or move into the possible moves list of the attacking piece
    # The king is also a valid piece, given that the king has possible moves.

    valid_pieces = []

    # Get the list of the player's pieces
    list_player_pieces = board.get_list_of_pieces(player.color)

    # Get the attacking piece.
    enemy_list = board.get_list_of_pieces(player.opponent_color)

    attacking_piece = enemy_list.select do |piece|
      piece.possible_moves.flatten(1).include?(king.current_pos)
    end

    return if attacking_piece.empty?

    attacking_piece = attacking_piece[0]

    attacking_piece_directional_list = attacking_piece.possible_moves.select do |directional_list|
      directional_list.include?(king.current_pos)
    end

    attacking_piece_directional_list = attacking_piece_directional_list.flatten(1)

    list_player_pieces.each do |piece|
      next if piece.possible_moves.empty?

      next unless piece_stop_check?(attacking_piece_directional_list,
                                    attacking_piece,
                                    piece)

      valid_pieces.push(piece)
    end
    # The attacking piece is the piece with the possible_moves list that can move on the king.
    # A piece is added to the valid list if the piece's possible_moves list has
    # the attacking_piece current_pos or a possible_move that is the same as
    # the attacking_piece possible_move.

    valid_pieces
  end

  def check_self_check_player_turn(board, player)
    loop do
      # Make a dupe of the board
      safe_board = board.deep_copy

      # Do move
      player_move_piece(player, board)

      # Update board with new info
      update_all_pieces(board, board.find_all_pieces)
      update_king_possible_spaces_when_attacked(board, player.color)

      # check player king
      check_self_logic = GameLogic.new(board)
      self_king = board.get_king(player.color)

      break unless check_self_logic.king_in_check?(self_king)

      print_error_self_check
      # if check -> copy dupe over current_board
      board.board = safe_board
    end
  end

  def piece_stop_check?(attacking_piece_list, attacking_piece, piece)
    attacking_piece_list
      .intersection(piece.possible_moves.flatten(1))&.length&.positive? ||
      piece.possible_moves.include?([attacking_piece.current_pos])
  end

  def player_move_piece(player, board)
    # display board
    print_board(board)

    # pick a piece to move.
    chosen_piece = setup_piece(board, player)
    chosen_initial = chosen_piece.current_pos

    # clear
    # clear_console

    # display board
    print_board(board)

    # Display which piece has been chosen
    print_chosen_piece(chosen_piece)

    # print all possible moves that the player can do.
    print_possible_moves_piece(chosen_piece)

    # get another player input (player, destination)
    chosen_destination = choose_destination(player, chosen_piece, board)

    # clear
    # clear_console

    # move piece, update old spot, update current pos, update new moves
    move_piece_complete(board, chosen_piece, chosen_initial, chosen_destination)

    # Check for pawn promotion condition if chosen_piece is a pawn
    pawn_promotion_procedure(chosen_piece, player, board) if chosen_piece.name == 'pawn'
  end

  def choose_destination(player, chosen_piece, board)
    loop do
      destination = player.player_input('destination')

      return destination if chosen_piece.possible_moves.flatten(1).include?(destination)

      # check if input is within possible moves for that piece

      clear_console
      print_board(board)
      puts "\n"

      print '       '
      puts "#{destination} is not a possible move."
      print_possible_moves_piece(chosen_piece)
    end
  end

  def move_piece_complete(board, piece, initial, destination)
    # Move piece to designated space.
    board.move_piece(initial, destination)

    # update pawn, king, or rook first turn if moved
    update_piece_first_turn(piece)

    # Make origin space empty.
    board.make_space_empty(initial)

    # update current_pos of the piece.
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

  def update_piece_moves(board, chosen_piece)
    chosen_piece&.update_possible_moves
    update_piece_with_object_collision(board, chosen_piece) if chosen_piece
  end

  def update_all_pieces(board, list_of_pieces)
    list_of_pieces.each { |piece| update_piece_moves(board, piece) }
  end

  def update_king_check_condition(game_logic, king)
    game_logic.king_in_check?(king) ? king.update_check(true) : king.update_check(false)
  end

  def update_king_possible_spaces_when_attacked(board, color)
    list = board.get_list_of_pieces(color)
    list.each do |chosen_piece|
      send_update_king_remove_check_spaces(board, chosen_piece.color, chosen_piece) if chosen_piece.name == 'king'
    end
  end

  def send_update_king_remove_check_spaces(board, color, king)
    enemy_list = board.get_opponent_list_pieces(color)
    array = []

    enemy_list.each do |piece|
      possible_list = piece.possible_moves
      possible_list.each do |directional_list|
        directional_list.each do |possible_space|
          array.push(possible_space)
        end
      end
    end
    king.remove_possible_spaces_where_check(array)
  end

  # Broken method, delete when complete.
  def remove_possible_moves_which_cause_check(base_board, player)
    # update(remove) the piece's possible move if moving that piece result in
    # a check.

    simulated_board = Board.new
    simulated_board.board = base_board.deep_copy

    # Get list of simulated pieces
    list_of_pieces = simulated_board.find_all_pieces

    list_of_pieces.each do |piece|
      piece_board = Board.new
      piece_board.board = simulated_board.deep_copy

      # Get the piece initial position
      initial = piece.current_pos

      # Get the destination which is the first possible move in a direction
      possible_list = piece.possible_moves

      # Break if the piece has no possible moves
      next if possible_list.empty?

      # valid_direction is an array of true or false.
      # This list tells you which direction the piece can go in without causing a check.
      valid_direction = []

      # For every direction the piece can go, each [], simulate a move in that direction
      possible_list.each do |directional_list|
        # Create a simulated board for each direction
        direction_board = Board.new
        direction_board.board = piece_board.deep_copy

        # Find the destination of each direction
        destination = directional_list[0]

        # perform the move in the direction
        move_piece_complete(direction_board, piece, initial, destination)

        # Update the possible moves of the attacking piece.
        update_all_pieces(direction_board, direction_board.find_all_pieces)

        # create a new game_logic
        direction_logic = GameLogic.new(direction_board)
        direction_king = direction_board.get_king(player.color)

        update_king_check_condition(direction_logic, direction_king)

        # If the move causes the king to be in check, then valid direction is false
        if direction_logic.king_in_check?(direction_king)
          valid_direction.push(false)
        else
          valid_direction.push(true)
        end
      end
      # Use the valid_direction t/f list to remove the direction_moves_list from the piece

      @chess_board.find_all_pieces.each do |base_piece|
        next unless base_piece.current_pos == initial

        valid_direction.each do |causes_check|
          # If false, remove the array
          base_piece.possible_moves.delete_if { !causes_check }
        end
      end
    end
  end

  def pawn_promotion_procedure(chosen_piece, player, board)
    # Create SpecialMoves object to handle pawn promotion.
    pawn_promotion = SpecialMoves.new(board)

    # Update pawn promotion status to check if it is on rank 0 or 7
    pawn_promotion.update_pawn_promotion_status(player.color)

    # If the pawn's promotion staus is true
    return unless chosen_piece.pawn_promotion

    pawn_board_position = chosen_piece.current_pos

    # Get player choice of piece for promotion
    choice = player.player_pawn_promotion_choice

    # Send message to board to switch out the pawn w/ said piece.
    board.promote_pawn(choice, pawn_board_position)
  end

  def print_chosen_piece(piece)
    print '       '
    puts "You have chosen a #{piece.color} #{piece.name} at " \
         "#{piece.current_pos}."
  end

  def print_error_self_check
    print '       '
    puts 'This is an invalid move. You must move a piece that will not cause a '

    print '       '
    puts 'check onto your own king.'

    puts "\n"
  end

  def print_possible_moves_piece(piece)
    print '       '
    puts "Please choose from these possible moves: #{piece.possible_moves}"
  end

  def print_board(board)
    board.display_board
  end

  def print_valid_pieces(list)
    print '       '
    print 'The valid pieces are: '
    list.each do |piece|
      print "#{piece.name} at #{piece.current_pos}, "
    end

    puts "\n"
  end

  def error_message_invalid_space(board, space, position)
    clear_console
    print_board(board)
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
    print_board(@chess_board)
    puts %(
       #{winner.upcase} has won!
    )
  end
end
