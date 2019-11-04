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
    return true if @guesses.include? @code || @guesses.size >= @max_turns
  end

  def make_guess(guess)
    return nil unless valid_code? guess

    if game_over?
      puts "Can't make a new guess; the game is already over!"
      return nil
    end

    response = evaluate_guess guess
    @guesses.push guess
    @responses.push response

    return response
  end

  def set_code(code)
    if guesses.size > 0
      puts "You can't change the code mid-game!"
      return false  # If it's mid-game, I don't want to bother with other checks
    end

    valid = valid_code? code
    @code = code.split("") if valid
    return valid
  end

  def to_s

  end

  private
  def count_matches(list1, list2)
    if list1.size != list2.size
      puts "Error in count_matches: array sizes do not match (#{list1.size} " \
           "vs. #{list2.size})"
      return 0
    end

    matches = 0
    list1.size.times { |i| matches += 1 if list1[i] == list2[i] }

    return matches
  end

  def evaluate_guess(guess)
    guess = guess.split ""
    total_pegs = 0
    unique_code_colors = @code.uniq
    unique_code_colors.each do |color|
      total_pegs += [guess.count(color), @code.count(color)].min
    end

    red_pegs = count_matches(guess, @code)
    white_pegs = total_pegs - red_pegs

    return ("+" * red_pegs) + ("-" * white_pegs)
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

board = MastermindBoard.new
board.set_code "GBRK"
puts board.make_guess "YYBB"
puts board.make_guess "KRRY"
puts board.make_guess "GKGY"
puts board.make_guess "RRKY"
puts board.make_guess "BRGK"
puts board.make_guess "GBRK"
