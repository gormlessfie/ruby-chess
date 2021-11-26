# frozen_string_literal: true

require './lib/board'
require './lib/player'
require './lib/game_logic'
require './lib/unit_collision'
require './lib/special_moves'
require './lib/save_loader'

require 'pry-byebug'

# This holds all the methods that runs the game such as turns.
class Game
  def initialize(black_player)
    @chess_board = Board.new
    @white_player = Player.new('white')
    @black_player = black_player
    @winner = nil
    @turn_counter = 0
    @current_turn = nil
  end

  def game_round
    while @winner.nil?
      player_turn(@chess_board, @white_player) if @winner.nil?
      player_turn(@chess_board, @black_player) if @winner.nil?
      increment_turn_counter if @winner.nil?
    end
  end

  def player_turn(board, player)
    update_current_turn(player.color)
    # Update all pieces at the start of every turn
    update_all_pieces(board, board.find_all_pieces)

    update_king_possible_spaces_when_attacked(board, 'white')
    update_king_possible_spaces_when_attacked(board, 'black')

    # Create game_logic with current board
    game_logic = GameLogic.new(board)
    player_king = board.get_king(player.color)

    # Check & update player king check
    update_king_check_condition(game_logic, player_king)

    # Check board to see if castling is possible and update rook and king for castling.
    castling_procedure(board, player, player_king)

    # Get list of valid pieces that the player can move
    valid_pieces = valid_pieces_for_player(board, player)

    # Check board for checkmate condition
    if find_valid_pieces_stop_check(board, player, player_king)&.length&.zero? &&
       game_logic.checkmate?(player_king)
      choose_winner(player.opponent_color)
      return if @winner
    end

    # Check board for stalemate condition
    if game_logic.determine_stalemate(valid_pieces, player_king)
      choose_winner('stalemate')
      return if @winner
    end

    # Check board for draw condition
    if game_logic.determine_draw_turns(@turn_counter)
      choose_winner('draw')
      return if @winner
    end

    # If player is checked, must either move king or a piece that stops the check.
    # A piece that stops the check is one that makes the space the king is on no longer
    # possible.
    # The piece should be able to eat the attacking piece, or move to a space
    # that is within the list of possible move space that blocks movement to
    # the king.
    if game_logic.king_in_check?(player_king)
      simulated_board = simulate_valid_move_when_check(board, player)
      board.board = simulated_board.deep_copy
    else
      # Every piece is simulated and updated at the start of every turn.
      check_self_check_player_turn(board, player)
    end
  end

  def setup_piece(board, player)
    loop do
      chosen_initial = nil
      loop do
        break if player.is_a?(ComputerPlayer)

        chosen_initial = game_options(board, player.player_input('select'))
        break if chosen_initial.is_a?(Array)
      end

      if player.is_a?(ComputerPlayer)
        chosen_initial = [1, 1]
      end

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

    if chosen_piece.name == 'king' && chosen_piece.castling
      castling_move(board, chosen_initial, chosen_destination, player)
    end

    # Check for pawn promotion condition if chosen_piece is a pawn
    pawn_promotion_procedure(chosen_piece, player, board) if chosen_piece.name == 'pawn'
  end

  def choose_destination(player, chosen_piece, board)
    loop do
      destination = if player.cpu?
                      player.computer_destination(chosen_piece)
                    else
                      player.player_input('destination')
                    end

      return destination if chosen_piece.possible_moves.flatten(1).include?(destination)

      # check if input is within possible moves for that piece

      # clear_console
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

  def update_current_turn(player)
    @current_turn = player
  end

  def send_update_king_remove_check_spaces(board, color, king)
    array = find_enemy_possible_moves(board, color)
    king.remove_possible_spaces_where_check(array.uniq)
  end

  def find_enemy_possible_moves(board, color)
    enemy_list = board.get_opponent_list_pieces(color)
    array = []

    enemy_list.each do |piece|
      possible_list = piece.possible_moves
      possible_list.each do |directional_list|
        # This does not add pawn movement into the list. Pawn attack added later.
        next if piece.name == 'pawn'

        directional_list.each do |possible_space|
          array.push(possible_space)
        end
      end

      # Adds the pawn attack_spaces
      next unless piece.name == 'pawn'

      # push the attack spaces of the pawn, not the movement direction
      pawn_collision = UnitCollision.new(board)
      left = pawn_collision.calc_pawn_potential_attack(piece, 0)
      right = pawn_collision.calc_pawn_potential_attack(piece, 1)

      array.push(left) unless left.nil?
      array.push(right) unless right.nil?
    end
    array
  end

  def valid_pieces_for_player(base_board, player)
    valid_pieces_list = []

    master_board = Board.new
    master_board.board = base_board.deep_copy

    player_pieces = master_board
                    .get_list_of_pieces(player.color)
                    .select { |piece| true unless piece.possible_moves.empty? }

    player_pieces.each do |sim_piece|
      initial = sim_piece.current_pos

      sim_board = Board.new
      sim_board.board = master_board.deep_copy

      valid_direction = []

      sim_piece.possible_moves.each do |directional_list|
        directional_board = Board.new
        directional_board.board = sim_board.deep_copy

        destination = directional_list[0]
        move_piece_complete(directional_board, sim_piece, initial, destination)
        update_all_pieces(directional_board, directional_board.find_all_pieces)

        directional_logic = GameLogic.new(directional_board)
        directional_king = directional_board.get_king(player.color)

        update_king_check_condition(directional_logic, directional_king)

        directional_king.check ? valid_direction.push(false) : valid_direction.push(true)
      end

      sim_board.get_list_of_pieces(player.color).each do |player_piece|
        next unless player_piece.current_pos == initial

        valid_direction.each do |causes_check|
          # If false, remove the array
          sim_piece.possible_moves.delete_if { !causes_check }
        end
      end
      valid_pieces_list.push(sim_piece) unless sim_piece.possible_moves.empty?
    end

    valid_pieces_list
  end

  def castling_procedure(board, player, player_king)
    enemy_moves = find_enemy_possible_moves(board, player.color)
    castling_check = SpecialMoves.new(board, player, enemy_moves)

    if castling_check.able_castling('left', player_king)
      puts '       Castling available with your left rook'
      castling_check.add_castling_spaces_king('left', player_king)
    end
    return unless castling_check.able_castling('right', player_king)

    puts 'Castling available with your right rook'
    castling_check.add_castling_spaces_king('right', player_king)
  end

  def castling_move(board, chosen_initial, chosen_destination, player)
    rook = board.get_list_of_pieces(player.color).select do |piece|
      piece.name == 'rook' && piece.castling
    end
    rook = rook[0]
    rook_destination = find_rook_destination(chosen_initial, chosen_destination)
    move_piece_complete(board, rook, rook.current_pos, rook_destination)
  end

  def find_rook_destination(chosen_initial, chosen_destination)
    case chosen_destination[1]
    when 2
      [chosen_initial[0], 3]
    when 6
      [chosen_initial[0], 5]
    end
  end

  def pawn_promotion_procedure(chosen_piece, player, board)
    # Create SpecialMoves object to handle pawn promotion.
    pawn_promotion = SpecialMoves.new(board, player)

    # Update pawn promotion status to check if it is on rank 0 or 7
    pawn_promotion.update_pawn_promotion_status

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
    # clear_console
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
    # clear_console
    intro_message
    game_round
    game_end_message(@winner)
  end

  def game_continue
    player_turn(@black_player) if @current_turn == 'black' && @winner.nil?
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
    return unless winner == 'stalemate'

    puts %(
      The game was a #{winner.upcase}.
    )
  end

  def save_current_game(board)
    saver = SaveLoader.new
    # clear_console
    saver.save_game(self)
    print_board(board)
  end

  def load_save_game(loaded_save)
    @chess_board = loaded_save.instance_variable_get(:@chess_board)
    @winner = loaded_save.instance_variable_get(:@winner)
    @turn_counter = loaded_save.instance_variable_get(:@turn_counter)
    @current_turn = loaded_save.instance_variable_get(:@current_turn)

    game_continue
  end

  def game_options(board, input)
    return input if input.is_a?(Array)

    exit if input.match(/Q/i)
    save_current_game(board) if input.match(/S/i)
    nil
  end
end
