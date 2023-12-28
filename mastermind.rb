# frozen_string_literal: true

# Mastermind game
module Mastermind
  # All the valid colors in this game
  COLORS = %w[RED GREEN BLUE YELLOW PURPLE PINK].freeze

  # This class represents the basic player
  class Player
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  # This class is for the CodeMaker player
  class CodeMaker < Player
    attr_reader :secret_code

    def initialize(name)
      super(name)
      @secret_code = nil
    end

    # Provides feedback about the guess in the form of black and white pegs
    def provide_feedback(secret_code, guess)
      black_pegs = count_correctly_placed(secret_code, guess)
      white_pegs = count_correct_colors(secret_code, guess) - black_pegs

      [black_pegs, white_pegs]
    end

    private

    # This methods returns the count of correctly placed colors
    def count_correctly_placed(secret_code, guess)
      secret_code.each_with_index.count { |color, index| guess[index] == color }
    end

    # This method returns the count of correct colors but in wrong order
    def count_correct_colors(secret_code, guess)
      secret_code.count { |color| guess.include?(color) }
    end
  end

  # This class represents the CodeMakerAI
  class CodeMakerAI < CodeMaker
    # This method generates a random secret code
    def generate_secret_code
      # Loops until the secret code is valid
      loop do
        @secret_code = [COLORS.sample, COLORS.sample, COLORS.sample, COLORS.sample]
        break if @secret_code.length == @secret_code.uniq.length
      end
      @secret_code
    end
  end

  # This class represents the Human Player
  class CodeMakerHuman < CodeMaker
    # This method gets a secret code from the user
    def generate_secret_code
      puts 'Enter a secret code (enter colors one by one): Available Colors are RED, GREEN, YELLOW, BLUE, PURPLE, PINK'
      @secret_code = []
      4.times do
        add_valid_color
      end
      @secret_code
    end

    private

    # This method adds a valid color to the secret_code array
    def add_valid_color
      loop do
        color = gets.chomp.upcase
        valid = validate_color(color)
        if valid
          @secret_code << color
          break
        end
        puts 'Invalid or already used color, please try again'
      end
    end

    # This function returns true if a color is valid else false
    def validate_color(color)
      COLORS.include?(color) && !@secret_code.include?(color)
    end
  end

  # This class is for the CodeBreaker player
  class CodeBreaker < Player
    attr_reader :attempts

    def initialize(name)
      super(name)
      @attempts = 12 # Sets the default attempts to 12
    end

    # This method decrements the attempts by 1
    def decrement_attempts
      @attempts -= 1
    end

    private

    # This method returns a valid color
    def valid_color
      color = COLORS.sample
      loop do
        color = COLORS.sample
        break if validate_color(color)
      end
      color
    end

    # This function returns true if a color is valid else false
    def validate_color(color)
      COLORS.include?(color) && !@guess.include?(color)
    end
  end

  # This class represents the CodeBreaker Human
  class CodeBreakerHuman < CodeBreaker
    # This method gets a guess from the user
    def make_guess
      puts "#{@name}, Its Guess # #{13 - @attempts}!"
      puts 'Enter your guess colors one by one: Available Colors are RED, GREEN, YELLOW, BLUE, PURPLE, PINK'
      @guess = []
      4.times do
        add_valid_color
      end
      @guess
    end

    private

    # This method adds a valid color to the guess array
    def add_valid_color
      loop do
        color = gets.chomp.upcase
        valid = validate_color(color)
        if valid
          @guess << color
          break
        end
        puts 'Invalid or already used color, please try again'
      end
    end
  end

  # This class represents the CodeBreaker AI
  class CodeBreakerAI < CodeBreaker
    # This method generates a guess for the AI
    def make_guess(guess_info = nil)
      puts "#{@name}, Its Guess # #{13 - @attempts}!"
      puts 'The AI chose: '
      # Loops until the guess is valid
      generate_guess(guess_info)
      p @guess
      @guess
    end

    # Provides exact feedback about the guess
    def provide_exact_ai_feedback(secret_code)
      [correctly_placed_colors(secret_code), correct_colors(secret_code)]
    end

    private

    # Generates a guess
    def generate_guess(guess_info)
      # If there is no guess info then get a random guess else a calculated guess
      if guess_info.nil?
        random_guess
      else
        calculated_guess(guess_info)
      end
    end

    # Returns a calculated guess based on the guess info argument
    def calculated_guess(guess_info)
      @guess.each_with_index do |color, index|
        @guess[index] = if guess_info[0][index] == color
                          color
                        else
                          valid_color
                        end
      end
    end

    # Gets a random guess
    def random_guess
      loop do
        @guess = [COLORS.sample, COLORS.sample, COLORS.sample, COLORS.sample]
        break if @guess.length == @guess.uniq.length
      end
    end

    # This methods returns the count of correctly placed colors
    def correctly_placed_colors(secret_code)
      secret_code.map.with_index { |color, index| color if @guess[index] == color }
    end

    # This method returns the count of correct colors but in wrong order
    def correct_colors(secret_code)
      @guess.filter { |color| secret_code.include?(color) }
    end
  end

  # This class will control the flow of the game
  class Game
    def initialize(code_breaker = nil, code_maker = nil)
      # Initializes 2 players, 1 CodeMaker, and 1 CodeBreaker
      @code_breaker = code_breaker
      @code_maker = code_maker
    end

    # Setups the game and asks the user if they want to be the CodeMaker or CodeBreaker
    def setup_game
      puts 'Do you want to be:'
      puts '1) CodeMaker'
      puts '2) CodeBreaker'
      puts 'Enter the corresponding number'

      input = 0
      loop do
        input = gets.chomp.to_i
        break if input >= 1 && input <= 3
      end

      generate_players(input)
    end

    # Starts the game loop
    def start_game
      # Generates a secret code
      @secret_code = @code_maker.generate_secret_code
      # Displays a game start message
      puts 'A SECRET CODE HAS BEEN CHOSEN! GUESS IT! or DIE!'
      play_game
    end

    private

    # Plays the game
    def play_game
      # Loops until the game is over
      loop do
        # Gets a guess from the player
        fetch_guess
        # Get the feedback on how close the guess was
        black_pegs, white_pegs = @code_maker.provide_feedback(@secret_code, @guess)
        # Displays the game i.e the pegs
        display_game(black_pegs, white_pegs)
        # Decrement the attempts
        @code_breaker.decrement_attempts
        # Prints a winner message if the player has won or lost
        print_winner_message
        # Breaks if the game has ended
        break if check_lose_condition || check_win_condition
      end
    end

    # Get a guess
    def fetch_guess
      @guess = if @guess.nil?
                 @code_breaker.make_guess
               else
                 @code_breaker.make_guess(@code_breaker.provide_exact_ai_feedback(@secret_code))
               end
    end

    # This method generates the players depending on what the player input was
    def generate_players(input)
      if input == 1
        @code_maker = CodeMakerHuman.new('Player (CodeMaker)')
        @code_breaker = CodeBreakerAI.new('AI (CodeBreaker)')
      elsif input == 2
        @code_maker = CodeMakerAI.new('AI (CodeMaker)')
        @code_breaker = CodeBreakerHuman.new('Player (CodeBreaker)')
      end
    end

    # This method displays the pegs
    def display_game(black_pegs, white_pegs)
      puts '+' * black_pegs + '-' * white_pegs
    end

    # This method prints the game end / winner message
    def print_winner_message
      puts "#{@code_breaker.name} has WON the game in #{12 - @code_breaker.attempts} attempt(s)" if check_win_condition
      puts "#{@code_breaker.name} has run out of attempts" if check_lose_condition
    end

    #  This method checks if the game has been won
    def check_win_condition
      black_pegs, _white_pegs = @code_maker.provide_feedback(@secret_code, @guess)
      return unless black_pegs == 4

      true
    end

    # This method checks if a game has been lost
    def check_lose_condition
      @code_breaker.attempts <= 0
    end
  end
end

# Creates a new game and starts playing it
game = Mastermind::Game.new
game.setup_game
game.start_game
