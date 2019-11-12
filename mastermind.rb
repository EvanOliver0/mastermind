class MastermindBoard
  attr_reader :colors, :guesses, :max_guesses, :responses, :code_length

  def initialize(colors = ["K", "W", "R", "G", "B", "Y"], code_length = 4,
                 max_guesses = 12)
    @colors = colors
    @code_length = code_length
    @max_guesses = max_guesses
    @guesses = []
    @responses = []
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
    end

    return response
  end

  def points
    points = @guesses.size
    if (@guesses.size == @max_guesses) && (!@guesses.include? @code)
      points += 1
    end
    return points
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
    representation = "*" * (@code_length * 2 + 3)
    representation += "\n*" + " " * @code_length + "|"
    representation += game_over? ? @code.join("") : ("?" * @code_length)
    representation += "*"
    (@max_guesses - 1).downto(0) do |i|
      if i > (@guesses.size - 1)
        representation += "\n*#{' ' * @code_length}|#{'-' * @code_length}*"
      else
        representation += "\n*#{@responses[i]}|#{@guesses[i].join('')}*"
      end
    end
    representation += "\n" + "*" * (@code_length * 2 + 3)
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
    blank = @code_length - total_pegs

    return (" " * blank) + ("-" * white_pegs) + ("+" * red_pegs)
  end

  def valid_code?(code)
    valid = true
    if code.size != @code_length
      puts "Please enter a #{@code_length}-character code."
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
  attr_reader :name, :score
  def initialize(name = "Player", colors, code_length)
    @name = name
    @score = 0
    @colors = colors
    @code_length = code_length
  end

  def choose_code
    code = ""
    @code_length.times do
      choice = (rand * @colors.size).to_i
      code += @colors[choice]
    end
    return code
  end

  def increase_score(points)
    @score += points
  end

  def make_guess(colors, length)
    choose_code
  end
end

class ComputerPlayer < Player
  def initialize(name, colors, code_length)
    super
    @possibilities = generate_combos(@colors, @code_length)
  end

  def choose_code
    return @possibilities.pop
  end

  def make_guess(past_guesses, past_responses)
    sleep 2
    if past_guesses.empty?
      guess = choose_code
    else
      good = false
      until good
        guess = choose_code
        good = good_guess?(guess, past_guesses, past_responses)
      end
    end
    puts guess
    return guess
  end

  private
  def generate_combos(colors, length)
    combos = []
    colors.repeated_permutation(length).each { |set| combos.push(set.join("")) }
    return combos.shuffle
  end

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

def get_code_length(min, max)
  valid = false
  until valid
    length = get_integer("How long should the code be? (#{min} - #{max}) ",
                         "Please enter a positive integer.")
    if length < min || length > max
      puts "Please enter a number between #{min} and #{max}."
    else
      valid = true
    end
  end
  return length
end

def get_colors
  puts "Colors are represented by single letters, like B or R."
  valid, confirmed = false, false
  until valid && confirmed
    print "Enter the colors you'd like to use (no spaces/commas): "
    raw_colors = gets.chomp
    valid = only_alphabetic? raw_colors
    if !valid
      puts "Please enter only letters."
      next
    end
    colors = raw_colors.upcase.split("").uniq
    puts "So these are the colors we'll be using:"
    puts colors.join ", "
    print "Is that right? (Y/n) "
    confirmation = gets.chomp.downcase
    confirmed = confirmation != "n"
  end
  return colors
end

def get_integer(message, error_message = "Invalid input.")
  valid  = false
  until valid
    print message
    input = gets.chomp
    valid = positive_integer? input
    puts error_message unless valid
  end
  return Integer(input)
end

def get_max_guesses
  return get_integer("How many guesses are allowed? ",
                     "Please enter a positive integer.")
end

# Max code length allowable, given n colors, to limit processing time to <= 5 s
def max_length_for(n)
  max = case n
    when 2 then 20
    when 3 then 13
    when 4 then 10
    when 5 then 9
    when 6 then 8
    when 7 then 7
    when 8 then 7
    when 9..12 then 6
    when 13..20 then 5
    else
      4
  end
  return max
end

def only_alphabetic?(text)
  return /[^a-zA-Z]/.match(text).nil?
end

def positive_integer?(text)
  return (Integer(text) > 0 rescue false)
end

puts "**** MASTERMIND ****"
print "Use default settings? (Y/n) "
response = gets.chomp

if response.downcase == "n"
  colors = get_colors()
  code_length = get_code_length(2, max_length_for(colors.size))
  max_guesses = get_max_guesses()
  board = MastermindBoard.new(colors, code_length, max_guesses)
else
  board = MastermindBoard.new
end

puts "\n"
puts "Ok, think you're a mastermind?"
puts "The codemaker will choose a secret code, and the codebreaker must"
puts "try to guess the secret code within *#{board.max_guesses}* tries!"
puts "A + means there's a match in the right position;"
puts "a - means there's match in the wrong position."
puts "The code will be *#{board.code_length}* characters long,"
puts "and made up of a combination of these letters:"
puts "#{board.colors.join(", ")}"
puts ""

print "Would you like to be the codemaker or codebreaker? (m/B) "
choice = gets.chomp.downcase
if choice == "m"
  codemaker = HumanPlayer.new("Human", board.colors, board.code_length)
  codebreaker = ComputerPlayer.new("Computer", board.colors, board.code_length)
else
  codemaker = ComputerPlayer.new("Computer", board.colors, board.code_length)
  codebreaker = HumanPlayer.new("Human", board.colors, board.code_length)
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

puts "#{board.points} points for #{codemaker.name}!"
