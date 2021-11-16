# frozen_string_literal: true

class Player
  def initialize(color)
    @color = color
  end

  def player_turn

  end

  def player_input
    loop do
      input_message
      input = gets.chomp
      return input.split(',').map(&:to_i) if input.match(/\d,\d/)

      puts "The input #{input} is invalid. It must be '#,#'"
    end
  end

  def input_message
    puts "It is #{@color}'s turn. Please input a selection in '#,#' form."
  end
end
