# frozen_string_literal: true

class Player
  def initialize(color)
    @color = color
  end

  def player_turn

  end

  def player_input
    loop do
      input = gets.chomp

      return input if input.match(/\[\d, *\d\]/)
    end
  end
end

p = Player.new

p.player_input
