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

  def set_code()

  end

  def to_s

  end

  private
  def evaluate_guess

  end
end
