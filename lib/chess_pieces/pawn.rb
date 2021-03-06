# frozen_string_literal: true

require './lib/chess_pieces/chess_pieces'

# A Pawn chess piece. This piece can advance forward 2 spaces on the first move
# and 1 space afterwards. This piece can attack diagonally, if there is a
# black piece 1 space diagonal from it in front.
class Pawn < ChessPieces
  attr_reader :first_turn, :pawn_attack_key_white, :pawn_attack_key_black,
              :pawn_promotion, :en_passant, :en_passant_recip

  attr_accessor :potential_attack_spaces

  def initialize(color, index)
    white_key = create_white_key
    black_key = create_black_key
    super('pawn', color, index, white_key, black_key)
    @first_turn = true
    @pawn_attack_key_white = [[-1, -1], [-1, 1]]
    @pawn_attack_key_black = [[1, -1], [1, 1]]
    @pawn_promotion = false
    @en_passant = false
    @en_passant_recip = false
  end

  def add_possible_attack_spaces(list)
    list.each do |attack_space|
      @possible_moves.push(attack_space.flatten(1)) unless attack_space.empty?
    end
  end

  def remove_possible_attack_spaces(list)
    list.each do |attack_space|
      @possible_moves.push(attack_space.flatten(1)) unless attack_space.empty?
    end
  end

  def update_first_turn_false
    @first_turn = false
    update_white_key
    update_black_key
  end

  def create_white_key
    [[-1, 0], [-2, 0]]
  end

  def create_black_key
    [[1, 0], [2, 0]]
  end

  def update_white_key
    @white_key.pop
  end

  def update_black_key
    @black_key.pop
  end

  def determine_icon
    white = "\u2659"
    black = "\u265F"
    super(black, white)
  end

  def update_pawn_promotion
    @pawn_promotion = true
  end

  def update_en_passant(condition)
    @en_passant = condition
  end

  def update_en_passant_recip(condition)
    @en_passant_recip = condition
  end
end
