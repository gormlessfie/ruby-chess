# frozen_string_literal: true

class Player

  attr_reader :color
  def initialize(color)
    @color = color
  end

  def player_input
    loop do
      input_message
      input = gets.chomp
      puts "\n"
      return input.split(',').map(&:to_i).reverse if input.match(/\d,\d/)

      puts "The input #{input} is invalid. It must be '#,#'"
      puts "\n"
    end
  end

  def input_message
    puts "It is #{@color}'s turn. Please input a selection in '#,#' form"
    print 'for the piece that you wish to move: '
  end
end
