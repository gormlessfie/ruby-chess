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

      return input.split(',').map(&:to_i) if input.match(/^[0-7]{1},[0-7]{1}$/)
      return input if input.match(/^[QS]{1}$/i)

      print '       '
      puts "The input #{input} is invalid. It must be '#y,#x'"
      puts "\n"
    end
  end

  def opponent_color
    @color.match('white') ? 'black' : 'white'
  end

  def player_pawn_promotion_choice
    valid_choices = %w[queen rook bishop knight]
    loop do
      pawn_explanation
      input = gets.chomp
      puts "\n"

      return input.downcase if valid_choices.include?(input)

      print '       '
      puts "The input #{input} is invalid. It must be one of the pieces listed."
      puts "\n"
    end
  end

  def cpu?
    false
  end

  private

  def pawn_explanation
    print '       '
    puts 'Your pawn can be promoted. Please choose from the following list.'
    print '       '
    puts 'The valid pieces are: "queen", "rook", "bishop", "knight"'
    puts "\n"

    print '       '
    print 'Please select the piece you wish to promote the pawn into: '
  end

  def input_message(type)
    puts "\n"
    print '       '
    if type == 'select'
      puts 'Input [Q] to quit. Input [S] to save.'
      puts "\n"
      puts "       It is #{@color}'s turn. Please input a selection in '#y,#x' form"
      print '       for the piece that you wish to move: '
    else
      print 'Please select where to move the piece: '
    end
  end
end
