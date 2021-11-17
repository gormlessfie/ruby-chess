# frozen_string_literal: true

class Player
  def initialize(color)
    @color = color
  end

  def player_turn
    # pick a space. (piece to move)
    # Generate possibles moves of that piece in that space
    # print all possible moves that the player can do.
    # get another player input (player, destination)
    # Move piece to designated space.
    # update current_pos of the piece
    # Make origin space empty.
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
    puts "It is #{@color}'s turn. Please input a selection in '#,#' form for the piece that you wish to move."
  end
end
