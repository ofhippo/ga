require './morse.rb'
class Game
  ALPHABET = ("a".."z").to_a + [" "]
  MAX_LETTERS_IN_ANSWER = 100

  def initialize(answer=nil)
    @answer = answer
    @answer ||= (rand(MAX_LETTERS_IN_ANSWER)+1).times.map{ ALPHABET[rand(26)] }.join
    @question = Morse.tap_out(@answer)
  end

  def question
    @question
  end

  def answer
    @answer
  end

  def guess(g)
    score = 0
    @question.split("").each_with_index do |letter, i|
                       score += 1 if @answer[i] == g[i % g.size]
                     end
    score.to_f / @answer.size
  end
end
