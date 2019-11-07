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
  def initialize
    @score = 0
  end

  def choose_code
    puts "Override choose_code with a child method!"
  end

  def increase_score(points)
    @score += points
  end

  def make_guess
    puts "Override make_guess with a child method!"
  end
end

class ComputerPlayer < Player
  def choose_code(colors, length)
    code = ""
    length.times do
      choice = (rand * colors.size).to_i
      code += colors[choice]
    end
    return code
  end

  def make_guess(colors, length)
    sleep 2
    guess = choose_code(colors, length)
    puts guess
    return guess
  end
end

class HumanPlayer < Player
  def choose_code(colors, length)
    print "Choose a secret code: "
    return gets.chomp
  end

  def make_guess(colors, length)
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
  codemaker = HumanPlayer.new
  codebreaker = ComputerPlayer.new
else
  codemaker = ComputerPlayer.new
  codebreaker = HumanPlayer.new
end

code = codemaker.choose_code(board.colors, board.spaces)
board.set_code code

puts board
while !board.game_over?
  print "Guess #{board.guesses.size + 1}: "
  guess = codebreaker.make_guess(board.colors, board.spaces)
  board.make_guess guess
  puts board
end

puts "Winner: #{board.victor}!"
