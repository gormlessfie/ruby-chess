# frozen_string_literal: true

# A player in Chess. The player chooses which pieces to move.
class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def player_input(type)
    loop do
      input_message(type)
      input = gets.chomp
      puts "\n"
      return input.split(',').map(&:to_i) if input.match(/\d,\d/)

      puts "The input #{input} is invalid. It must be '#y,#x'"
      puts "\n"
    end
  end

  def input_message(type)
    puts "\n"
    print '       '
    if type == 'select'
      puts "It is #{@color}'s turn. Please input a selection in '#y,#x' form"
      print '       '
      print 'for the piece that you wish to move: '
    else
      print 'Please select where to move the piece: '
    end
  end
end
