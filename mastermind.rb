class MastermindBoard
  attr_reader :colors, :guesses, :max_turns, :responses, :spaces, :victor

  def initialize(colors = ["K", "W", "R", "G", "B", "Y"], spaces = 4,
                 max_turns = 12)
    @colors = colors
    @spaces = spaces
    @max_turns = max_turns
    @guesses = []
    @responses = []
    @victor = nil
  end

  def game_over?

  end

  def make_guess

  end

  def set_code(code)
    if guesses.size > 0
      puts "You can't change the code mid-game!"
      return false  # If it's mid-game, I don't want to bother with other checks
    end

    valid = valid_code? code
    @code = characters if valid
    return valid
  end

  def to_s

  end

  private
  def evaluate_guess

  end

  def valid_code?(code)
    valid = true
    if code.length != @spaces
      puts "Please enter a #{@spaces}-character code."
      valid = false
    end

    characters = code.split ""
    characters.each do |character|
      if !colors.include? character
        puts "Invalid character: #{character}"
        valid = false
      end
    end

    return valid
  end
end
