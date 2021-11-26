# frozen_string_literal: true

require './lib/player'

# This is a computer player that will choose a random valid move each turn
class ComputerPlayer < Player
  attr_reader :piece, :type

  def initialize
    @type = 'cpu'
    # CPU color is random between white and black
    super('black')
  end

  def player_input(valid_pieces_list)
    # This should have an valid_piece_list as argument
    # CPU chooses a random piece with #sample
    # The cpu then chooses a random possible move from the random piece
    valid_pieces_list.each do |piece|
      p "#{piece.name} #{piece.current_pos}"
    end
    valid_pieces_list.sample.current_pos
  end

  def computer_destination(chosen_piece)
    chosen_piece.possible_moves.flatten(1).sample
  end

  # CPU will always choose queen as pawn promotion
  def player_pawn_promotion_choice
    'queen'
  end

  def cpu?
    true
  end

  private

  def rand_color
    color_list = %w[white black]
    color_list.sample
  end
end
