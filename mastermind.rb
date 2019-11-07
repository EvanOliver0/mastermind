class MastermindBoard
  attr_reader :colors, :guesses, :max_guesses, :responses, :spaces, :victor

  def initialize(colors = ["K", "W", "R", "G", "B", "Y"], spaces = 4,
                 max_guesses = 12)
    @colors = colors
    @spaces = spaces
    @max_guesses = max_guesses
    @guesses = []
    @responses = []
    @victor = nil
  end

  def game_over?
    return true if (@guesses.include? @code) || (@guesses.size >= @max_guesses)
  end

  def make_guess(guess)
    if game_over?
      puts "Can't make a new guess; the game is already over!"
      return nil
    end

    guess = guess.upcase.split ""
    return nil unless valid_code? guess

    response = evaluate_guess guess
    @guesses.push guess
    @responses.push response

    if @guesses.size > @max_guesses
      puts "How did you manage to make more guesses than allowed?"
      puts "Max guesses: #{@max_guesses}; total guesses: #{@guesses.size}"
    elsif guess == @code
      @victor = "codebreaker"
    elsif @guesses.size == @max_guesses
      @victor = "codemaker"
    end

    return response
  end

  def set_code(code)
    code = code.upcase.split ""
    if guesses.size > 0
      puts "You can't change the code mid-game!"
      return false  # If it's mid-game, I don't want to bother with other checks
    end

    valid = valid_code? code
    @code = code if valid
    return valid
  end

  def to_s
    representation = "*" * (@spaces * 2 + 3)
    representation += "\n*" + " " * @spaces + "|"
    representation += game_over? ? @code.join("") : ("?" * @spaces)
    representation += "*"
    (@max_guesses - 1).downto(0) do |i|
      if i > (@guesses.size - 1)
        representation += "\n*#{' ' * @spaces}|#{'-' * @spaces}*"
      else
        representation += "\n*#{@responses[i]}|#{@guesses[i].join('')}*"
      end
    end
    representation += "\n" + "*" * (@spaces * 2 + 3)
    return representation
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
    total_pegs = 0
    unique_code_colors = @code.uniq
    unique_code_colors.each do |color|
      total_pegs += [guess.count(color), @code.count(color)].min
    end

    red_pegs = count_matches(guess, @code)
    white_pegs = total_pegs - red_pegs
    blank = @spaces - total_pegs

    return (" " * blank) + ("-" * white_pegs) + ("+" * red_pegs)
  end

  def valid_code?(code)
    valid = true
    if code.size != @spaces
      puts "Please enter a #{@spaces}-character code."
      valid = false
    end

    code.each do |color|
      if !colors.include? color
        puts "Invalid color: #{color}"
        valid = false
      end
    end

    return valid
  end
end

class Player
  attr_reader :score
  def initialize(colors, spaces)
    @score = 0
    @colors = colors
    @code_length = spaces
  end

  def choose_code
  end

  def increase_score(points)
    @score += points
  end

  def make_guess(colors, length)
  end
end

class ComputerPlayer < Player
  def initialize(colors, spaces)
    super
    @possibilities = @colors
  end

  def choose_code
    code = ""
    @code_length.times do
      choice = (rand * @possibilities.size).to_i
      code += @possibilities[choice]
    end
    return code
  end

  def make_guess(past_guesses, past_responses)
    sleep 2
    if past_guesses.empty?
      guess = choose_code()
    else
      remove_impossible(past_guesses.last, past_responses.last)
      good = false
      until good
        guess = choose_code()
        good = good_guess?(guess, past_guesses, past_responses)
      end
    end
    puts guess
    return guess
  end

  private
  def good_guess?(guess, past_guesses, past_responses)
    test_board = MastermindBoard.new(@colors, @code_length, past_guesses.size)
    test_board.set_code guess
    past_guesses.size.times do |i|
      past_guess = past_guesses[i].join("")
      past_response = past_responses[i]
      return false unless test_board.make_guess(past_guess) == past_response
    end
    return true
  end

  def remove_impossible(guess, response)
    pegs = response.length - response.count(" ")
    @possibilities -= guess if pegs == 0
  end
end

class HumanPlayer < Player
  def choose_code
    print "Choose a secret code: "
    return gets.chomp
  end

  def make_guess(past_guesses, past_responses)
    return gets.chomp
  end
end

board = MastermindBoard.new
puts "Think you're a mastermind?"
puts "The codemaker will choose a secret code, and the codebreaker must"
puts "try to guess the secret code within *#{board.max_guesses}* tries!"
puts "A + means there's a match in the right position;"
puts "a - means there's match in the wrong position."
puts "The code will be *#{board.spaces}* characters long,"
puts "and made up of a combination of these letters:"
puts "#{board.colors.join(", ")}"
puts ""

print "Would you like to be the codemaker or codebreaker? (m/B) "
choice = gets.chomp.downcase
if choice == "m"
  codemaker = HumanPlayer.new(board.colors, board.spaces)
  codebreaker = ComputerPlayer.new(board.colors, board.spaces)
else
  codemaker = ComputerPlayer.new(board.colors, board.spaces)
  codebreaker = HumanPlayer.new(board.colors, board.spaces)
end

valid_code = false
until valid_code
  code = codemaker.choose_code
  valid_code = board.set_code code
end

puts board
while !board.game_over?
  print "Guess #{board.guesses.size + 1}: "
  guess = codebreaker.make_guess(board.guesses, board.responses)
  board.make_guess guess
  puts board
end

puts "Winner: #{board.victor}!"
