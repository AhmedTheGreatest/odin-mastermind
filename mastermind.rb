# frozen_string_literal: true

# Mastermind game
module Mastermind
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

    def generate_secret_code
      loop do
        @secret_code = [COLORS.sample, COLORS.sample, COLORS.sample, COLORS.sample]
        break if @secret_code.length == @secret_code.uniq.length
      end
      @secret_code
    end

    def provide_feedback(secret_code, guess)
      black_pegs = count_correctly_placed(secret_code, guess)
      white_pegs = count_correct_colors(secret_code, guess) - black_pegs

      [black_pegs, white_pegs]
    end

    private

    def count_correctly_placed(secret_code, guess)
      secret_code.each_with_index.count { |color, index| guess[index] == color }
    end

    def count_correct_colors(secret_code, guess)
      secret_code.count { |color| guess.include?(color) }
    end
  end

  # This class is for the CodeBreaker player
  class CodeBreaker < Player
    attr_reader :attempts

    def initialize(name)
      super(name)
      @attempts = 12
    end

    def make_guess
      puts "#{@name}, enter your guess colors one by one: "
      @guess = []
      4.times do
        add_valid_color
      end
      @guess
    end

    def decrement_attempts
      @attempts -= 1
    end

    private

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

    def validate_color(color)
      COLORS.include?(color) && !@guess.include?(color)
    end
  end

  # This class will control the flow of the game
  class Game
    def initialize
      @code_maker = CodeMaker.new('Player 1 CodeMaker')
      @code_breaker = CodeBreaker.new('Player 2 CodeBreaker')
    end

    def start_game
      @secret_code = @code_maker.generate_secret_code
      puts 'A SECRET CODE HAS BEEN CHOSEN! GUESS IT! or DIE!'
      loop do
        @guess = @code_breaker.make_guess
        black_pegs, white_pegs = @code_maker.provide_feedback(@secret_code, @guess)
        display_game(black_pegs, white_pegs)
        @code_breaker.decrement_attempts
        print_winner_message
        break if check_lose_condition || check_win_condition
      end
    end

    def display_game(black_pegs, white_pegs)
      puts '+' * black_pegs + '-' * white_pegs
    end

    def print_winner_message
      puts "#{@code_breaker.name} has WON the game in #{12 - @code_breaker.attempts} attempt(s)" if check_win_condition
      puts "#{@code_breaker.name} has WON the game in #{12 - @code_breaker.attempts} attempt(s)" if check_lose_condition
    end

    def check_win_condition
      black_pegs, _white_pegs = @code_maker.provide_feedback(@secret_code, @guess)
      return unless black_pegs == 4

      true
    end

    def check_lose_condition
      @code_breaker.attempts <= 0
    end
  end
end

game = Mastermind::Game.new
game.start_game
