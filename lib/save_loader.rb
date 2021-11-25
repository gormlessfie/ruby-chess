# frozen_string_literal: true

# This saves and loads the game. This will save the current state of the board.
class SaveLoader
  def setup_save_folder
    create_save_dir
  end

  def save_game(game)
    setup_save_folder

    Dir.chdir('saves')

    serialized_object = Marshal.dump(game)
    File.open(user_save_name_choice, 'w') { |file| file.write(serialized_object) }

    Dir.chdir('..')
    print '       '
    puts 'Save complete! You can exit at any time.'
  end

  def load_game
    setup_save_folder

    if Dir.empty?('saves')
      puts "\n\n\n      No save files found."
      return nil
    end

    save_list = Dir.children('saves')
    puts "\n\n\n       LIST OF SAVES"
    save_list.each_with_index { |save_name, idx| puts "         #{idx + 1} : #{save_name}" }

    user_input = save_user_choice(save_list)
    system('clear')

    Dir.chdir('saves')

    save = File.open(save_list[user_input - 1].to_s)

    Dir.chdir('..')

    Marshal.load(save)
  end

  private

  def create_save_dir
    Dir.mkdir('saves') unless Dir.exist?('saves')
  end

  def save_user_choice(save_list)
    print '       '
    print 'Please choose a save to load: '
    loop do
      input = gets.chomp.to_i
      return input if input.between?(1, save_list.length)

      print '       '
      puts 'You must select a choice that is on the list.'
    end
  end

  def user_save_name_choice
    print '       '
    print 'Please enter a name for your save: '

    gets.chomp
  end
end
