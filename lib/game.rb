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
  def initialize(white_player, black_player)
    @chess_board = Board.new
    @white_player = white_player
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

    # Get list of valid pieces that the player can move
    valid_pieces = valid_pieces_for_player(board, player)
    valid_pieces = only_valid_move_when_check(board, player) if game_logic.king_in_check?(player_king)

    # Check board for checkmate condition
    if find_valid_pieces_stop_check(board, player, player_king)&.length&.zero? &&
       game_logic.checkmate?(player_king)
      choose_winner(player.opponent_color)
      return if @winner
    end

    # Check board for stalemate condition
    if game_logic.determine_stalemate(valid_pieces, player_king)
      choose_winner('STALEMATE')
      return if @winner
    end

    # Check board for draw condition
    if game_logic.determine_draw_turns(@turn_counter)
      choose_winner('draw')
      return if @winner
    end

    if game_logic.determine_draw_king_king
      choose_winner('DRAW')
      return if @winner
    end

    # If player is checked, must either move king or a piece that stops the check.
    # A piece that stops the check is one that makes the space the king is on no longer
    # possible.
    # The piece should be able to eat the attacking piece, or move to a space
    # that is within the list of possible move space that blocks movement to
    # the king.
    check_self_check_player_turn(valid_pieces, board, player)
  end

  def setup_piece(valid_list, board, player)
    loop do
      chosen_initial = nil
      loop do
        break if player.cpu?

        chosen_initial = game_options(board, player.player_input('select'))
        break if chosen_initial.is_a?(Array)
      end
      chosen_initial = player.player_input(valid_list) if player.cpu?

      chosen_space = board.board[chosen_initial[0]][chosen_initial[1]]

      return chosen_space.piece if chosen_space.piece &&
                                   chosen_space.piece.color == player.color &&
                                   chosen_space.piece.name == 'pawn' &&
                                   chosen_space.piece.en_passant

      return chosen_space.piece if chosen_space.piece &&
                                   chosen_space.piece.color == player.color &&
                                   !chosen_space.piece.possible_moves.empty? &&
                                   piece_in_valid_list?(chosen_space.piece, valid_list)

      error_message_invalid_space(board, chosen_space, chosen_initial, valid_list)
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

  def piece_in_valid_list?(chosen_piece, valid_list)
    valid_list.each do |valid_piece|
      return true if valid_piece.name == chosen_piece.name &&
                     valid_piece.current_pos == chosen_piece.current_pos
    end

    false
  end

  def simulate_valid_move_when_check(base_board, player)
    simulated_board = nil
    loop do
      print '       '
      puts 'You must stop the check. Please select a unit' \
           'that can move to protect your king!'

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

  def only_valid_move_when_check(base_board, player)
    king = base_board.get_king(player.color)
    valid_list = find_valid_pieces_stop_check(base_board, player, king)
    remove_invalid_moves_from_valid_pieces_when_check(base_board, player, valid_list, king)
    valid_list
  end

  def remove_invalid_moves_from_valid_pieces_when_check(board, player, valid_list, king)
    # Get the attacking piece
    att_pieces = board.attacking_piece(player, king)
    att_pieces.each do |attacking_piece|
      # Get the directional list of the attacking_piece which contains the enemy king
      att_piece_dir_list = board.attacking_piece_directional_list(attacking_piece, king)
      att_piece_dir_list[0].push(attacking_piece.current_pos)

      # For each valid_piece, possible_moves directional list moves by removing
      # all moves that are not in the att_piece dir list
      valid_list.each do |valid_piece|
        remove_invalid_moves_from_king_when_check(board, player, valid_piece) if valid_piece.name == 'king'
        next if valid_piece.name == 'king'

        # check if att_piece_dir_list includes the space that piece can move into.
        # if it it is valid, then it means that the piece can stop the check.
        valid_piece.possible_moves.each_with_index do |directional_list, idx|
          valid_moves = []
          directional_list.each do |dir_space|
            if att_piece_dir_list[0].include?(dir_space)
              # sim the move, if the dir_space also stops the check, then it is pushed, otherwise, no.
              # create a new board object to simulate the move
              sim_board = Board.new
              sim_board.board = board.deep_copy

              sim_piece = Marshal.load(Marshal.dump(valid_piece))

              # perform the move on the simulated board
              move_piece_complete(sim_board, sim_piece, sim_piece.current_pos,
                                  dir_space, player)

              # Update the possible moves of the attacking piece.
              update_all_pieces(sim_board, sim_board.find_all_pieces)

              # create a new game_logic
              sim_logic = GameLogic.new(sim_board)

              sim_king = sim_board.get_king(player.color)

              update_king_check_condition(sim_logic, sim_king)

              valid_moves.push(dir_space) unless sim_king.check
            end
          end
          valid_piece.update_directional_list(idx, valid_moves)
        end
        valid_piece.remove_empty_direction_possible_moves
      end
    end
  end

  def remove_invalid_moves_from_king_when_check(board, player, valid_piece)
    # The king still has the valid move of moving away from the attacking piece
    # This does not work because the king would still be in check if the piece
    # can go indefinitely in a direction.
    # ex: queen at 1, 1 ; king at 2, 1; king possible moves will include 3, 1; even though it would still be in check.
    # This is a oversight because queen can only move to 2, 1.

    valid_initial = valid_piece.current_pos
    valid_directions = valid_piece.possible_moves

    # To simulate it, I need to make a copy of the board for every direction.
    valid_directions.each_with_index do |dir_list, idx|
      valid_moves = []

      dir_list.each do |dir_space|
        # Create a new sim board
        sim_board = Board.new
        sim_board.board = board.deep_copy

        # Get sim king
        sim_king = sim_board.get_king(player.color)

        # perform the move on the simulated board
        move_piece_complete(sim_board, sim_king, valid_initial, dir_space, player)

        # Update the possible moves of the attacking piece.
        update_all_pieces(sim_board, sim_board.find_all_pieces)

        # create a new game_logic
        sim_logic = GameLogic.new(sim_board)

        # Update the king check condition
        update_king_check_condition(sim_logic, sim_king)

        # Push the possible space
        valid_moves.push(dir_space) unless sim_king.check
      end
      # replace the directional list of the piece.
      valid_piece.update_directional_list(idx, valid_moves)
    end
    # Remove all empty direction lists that are empty
    valid_piece.remove_empty_direction_possible_moves
  end

  def find_valid_pieces_stop_check(board, player, king)
    # A valid piece is a piece with a possible moves list that can eat the
    # attacking piece or move into the possible moves list of the attacking piece
    # The king is also a valid piece, given that the king has possible moves.
    # An invalid piece is one that can eat a piece that is causing check, but causes self-check
    valid_pieces = []
    # Get the list of the player's pieces
    list_player_pieces = board.get_list_of_pieces(player.color)
    attacking_pieces = board.attacking_piece(player, king)

    return if attacking_pieces.empty?

    attacking_pieces.each do |attacking_piece|
      att_piece_dir_list = board.attacking_piece_directional_list(attacking_piece, king).flatten(1)
      att_piece_dir_list.push(attacking_piece.current_pos)
      list_player_pieces.each do |piece|
        valid_pieces.push(piece) if piece.name == 'king' && !piece.possible_moves.empty?
        next if piece.possible_moves.empty?
        next unless piece_stop_check?(att_piece_dir_list,
                                      attacking_piece,
                                      piece)

        valid_pieces.push(piece)
      end
    end
    # The attacking piece is the piece with the possible_moves list that can move on the king.
    # A piece is added to the valid list if the piece's possible_moves list has
    # the attacking_piece current_pos or a possible_move that is the same as
    # the attacking_piece possible_move.
    valid_pieces.uniq
  end

  def check_self_check_player_turn(valid_list, board, player)
    safe_board = nil
    loop do
      # Make a dupe of the board
      safe_board = Board.new
      safe_board.board = board.deep_copy

      # Do move
      player_move_piece(valid_list, player, safe_board)

      # Update board with new info
      update_all_pieces(safe_board, safe_board.find_all_pieces)
      update_king_possible_spaces_when_attacked(safe_board, player.color)

      # check player king
      check_self_logic = GameLogic.new(safe_board)
      self_king = safe_board.get_king(player.color)

      break unless check_self_logic.king_in_check?(self_king)

      print_error_self_check
      # if check -> copy dupe over current_board
      # Once it is no longer in check
    end
    board.board = safe_board.board
  end

  def piece_stop_check?(attacking_piece_list, attacking_piece, piece)
    attacking_piece_list
      .intersection(piece.possible_moves.flatten(1))&.length&.positive? ||
      piece.possible_moves.include?([attacking_piece.current_pos])
  end

  def player_move_piece(valid_list, player, board)
    # display board
    print_board(board)

    # pick a piece to move.
    chosen_piece = setup_piece(valid_list, board, player)
    chosen_initial = chosen_piece.current_pos

    # clear
    # clear_console

    # Check if chosen piece is a pawn and en_passant
    # If chosen piece is a pawn & en_passant, then add the en_passant move
    # To the chosen piece.
    special_moves = SpecialMoves.new(board, player) if chosen_piece.name == 'pawn'
    en_passant_dest = nil
    en_passant_recip = nil
    if chosen_piece.name == 'pawn' && chosen_piece.en_passant
      # Update the possible move of this pawn
      en_passant_recip = special_moves.find_en_passant_recip_enemy
      special_moves.add_en_passant_attack_move(en_passant_recip, chosen_piece)
      en_passant_dest = special_moves.en_passant_attack_move_pos(en_passant_recip, en_passant_recip.current_pos)
    end

    castling_procedure(board, player, chosen_piece) if chosen_piece.name == 'king'

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
    move_piece_complete(board, chosen_piece, chosen_initial, chosen_destination, player)

    if chosen_piece.name == 'king' && chosen_piece.castling &&
       chosen_piece.current_pos == find_king_destination(chosen_destination)
      castling_move(board, chosen_initial, chosen_destination, player)
    end

    if chosen_piece.name == 'pawn' &&
       chosen_piece.en_passant &&
       chosen_piece.current_pos == en_passant_dest
      en_passant_move(board, en_passant_recip)
    end

    update_players_pawns_en_passant_false(board, chosen_piece)
    # Delete en_passant_recip if chosen_piece.en_passant && performed en passant move.
    # To see if en passant is performed, check to see if pawn moved to dest.

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

  def move_piece_complete(board, piece, initial, destination, player = nil)
    # Move piece to designated space.
    board.move_piece(initial, destination)

    # update pawn, king, or rook first turn if moved
    update_piece_first_turn(piece)

    # Make origin space empty.
    board.make_space_empty(initial)

    # update current_pos of the piece.
    piece.update_current_pos(destination)

    # update pawn en passant_recip
    special_moves = SpecialMoves.new(board, player)
    check_pawn_en_passant_recip(piece, initial, destination)
    # p "#{piece.name} #{piece.color} en_passant_recip:#{piece.en_passant_recip} en_passant: #{piece.en_passant}" if piece.name == 'pawn'
    # check en_passant_recip, if true, then set en_passant on adj pawns, if exist
    if piece.name == 'pawn' && piece.en_passant_recip
      make_left_right_pawns_en_passant(special_moves)
    end
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
      if chosen_piece.name == 'king' && chosen_piece.color == color
        send_update_king_remove_check_spaces(board, chosen_piece.color, chosen_piece)
      end
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
      possible_list = nil
      possible_list = piece.possible_moves unless piece.name == 'pawn'
      possible_list&.each do |directional_list|
        # This does not add pawn movement into the list. Pawn attack added later.
        next if piece.name == 'pawn'

        directional_list.each do |possible_space|
          array.push(possible_space)
        end
      end

      # Adds the pawn attack_spaces
      if piece.name == 'pawn'
        # push the attack spaces of the pawn, not the movement direction
        pawn_collision = UnitCollision.new(board)
        left = pawn_collision.calc_pawn_potential_attack(piece, 0)
        right = pawn_collision.calc_pawn_potential_attack(piece, 1)

        array.push(left) unless left.nil?
        array.push(right) unless right.nil?
      end
    end
    array
  end

  # This provides a list of sim pieces which have already moved. I want the list
  # of pieces from the original board that is valid to move without causing king
  # to be checked.
  def valid_pieces_for_player(base_board, player)
    valid_pieces_list = []

    master_board = Board.new
    master_board.board = base_board.deep_copy

    player_pieces = master_board
                    .get_list_of_pieces(player.color)
                    .select { |piece| true unless piece.possible_moves.empty? }

    base_list = base_board
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
        destination = destination.flatten
        move_piece_complete(directional_board, sim_piece, initial, destination, player)
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

      base_piece = base_list.select { |piece| piece.current_pos == initial }
      valid_pieces_list.push(base_piece[0]) unless sim_piece.possible_moves.empty?
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
    return if rook.empty?

    rook = rook[0]
    rook_destination = find_rook_destination(chosen_initial, chosen_destination)
    move_piece_complete(board, rook, rook.current_pos, rook_destination, player)
  end

  def make_left_right_pawns_en_passant(special_moves)
    en_passant_recip = special_moves.find_en_passant_recip
    return if en_passant_recip.nil?

    # Check the space left and right for your player's pawn
    left_piece = special_moves.adj_piece_en_passant_recip(en_passant_recip, -1)
    right_piece = special_moves.adj_piece_en_passant_recip(en_passant_recip, 1)

    left_piece.update_en_passant(true) if !left_piece.nil? && left_piece.name == 'pawn'
    right_piece.update_en_passant(true) if !right_piece.nil? && right_piece.name == 'pawn'
  end

  def update_players_pawns_en_passant_false(board, piece)
    list_player_pawns = board.get_list_pawns(piece.color)
    list_player_pawns.each { |pawn| pawn.update_en_passant(false) }
  end

  def check_pawn_en_passant_recip(piece, initial, destination)
    return unless piece.name == 'pawn'

    color = piece.color

    return piece.update_en_passant_recip(true) if color == 'white' && (destination[0] - initial[0]) == -2

    return piece.update_en_passant_recip(true) if color == 'black' && (destination[0] - initial[0]) == 2

    piece.update_en_passant_recip(false)
  end

  def en_passant_move(board, en_passant_recip)
    board.make_space_empty(en_passant_recip.current_pos)
  end

  def find_rook_destination(chosen_initial, chosen_destination)
    case chosen_destination[1]
    when 2
      [chosen_initial[0], 3]
    when 6
      [chosen_initial[0], 5]
    end
  end

  def find_king_destination(chosen_destination)
    case chosen_destination[1]
    when 2
      [chosen_destination[0], 2]
    when 6
      [chosen_destination[0], 6]
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
    list.uniq.each do |piece|
      print "#{piece.name} at #{piece.current_pos}, "
    end

    puts "\n"
  end

  def error_message_invalid_space(board, space, position, valid_list)
    # clear_console
    print_board(board)
    puts "\n"
    print '       '
    if space.piece.nil?
      puts "You have selected #{position} which contains no chess piece."
    elsif space.piece.possible_moves.empty?
      puts "There are no possible spaces for this #{space.piece.color} " \
           "#{space.piece.name} to move to."
    elsif !piece_in_valid_list?(space.piece, valid_list)
      puts 'You must choose a piece that is valid.'
      print '       '
      print 'The valid pieces are: '
      valid_list.each { |piece| print "#{piece.name} at #{piece.current_pos} #{piece.possible_moves}, " }
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

  def game_continue(board)
    player_turn(board, @black_player) if @current_turn == 'black' && @winner.nil?
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
    case winner
    when 'white', 'black'
      puts %(
        #{winner.upcase} has won!
      )
    when 'STALEMATE'
      puts %(
        The game was a #{winner.upcase}.
      )
    when 'DRAW'
      puts %(
        The game was a #{winner.upcase}.
      )
    end
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
    @white_player = loaded_save.instance_variable_get(:@white_player)
    @black_player = loaded_save.instance_variable_get(:@black_player)
    game_continue(@chess_board)
  end

  def game_options(board, input)
    return input if input.is_a?(Array)

    exit if input.match(/Q/i)
    save_current_game(board) if input.match(/S/i)
    nil
  end
end
