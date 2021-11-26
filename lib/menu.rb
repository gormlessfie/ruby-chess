# frozen_string_literal: true

require './lib/game'
require './lib/save_loader'
require './lib/player'
require './lib/cpu'

# This is the menu which gives the player options on how to create the game.
class Menu
  def game_menu
    selection
  end

  private

  def print_menu
    puts %(
      This is the game of Chess.

      (1) Start a new game
      (2) Load a saved game

    )
  end

  def print_choose_player_two
    puts %(
      Who will you play against:

      (1) Computer
      (2) Human player

    )
  end

  def get_menu_input(min, max)
    print '      Please make a selection: '
    loop do
      choice = gets.chomp.to_i
      return choice if choice.between?(min, max)

      puts "      Invalid selection. Input must be #{min} or #{max}"
    end
  end

  def load_menu
    loader = SaveLoader.new
    loaded_game = loader.load_game

    return false if loaded_game.nil?

    game = Game.new(Player.new('black'))
    game.load_save_game(loaded_game)

    true
  end

  def start_new_game(player_two = Player.new('black'))
    game = Game.new(player_two)
    game.game_start
  end

  def selection
    loop do
      print_menu
      choice = get_menu_input(1, 2)
      system('clear')
      case choice
      when 1
        computer_play? ? start_new_game(ComputerPlayer.new) : start_new_game
        break
      when 2
        break if load_menu
      end
    end
  end

  def computer_play?
    print_choose_player_two
    return true if get_menu_input(1, 2) == 1

    false
  end
end
