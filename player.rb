require './morse.rb'
class Player
  #genome: for each of 81 possible 4-slots of dot-dash-nothing combinations
  #assign a letter
  #e.g. aaaaaaaaaaaaaaaaaaaaaaaaaa, abcdefghijklmnopqrstuvwxyz
  #index of gene is morse element in base 3
  #

  def initialize(strategy=nil)
    @strategy = strategy || random_strategy
  end

  def decode(morse_string)
    morse_string.split(Morse::WORD_DELIMITER).
      map do |morse_word|
        morse_word.split(Morse::LETTER_DELIMITER).map{|e| decode_letter(e)}.join
      end.join(" ")
  end

  def decode_letter(morse_letter)
    @strategy[digitize(morse_letter)]
  end

  def strategy
    @strategy
  end

  def strategy=(x)
    @strategy = x
  end

  def fitness
    @fitness
  end

  def fitness=(x)
    @fitness = x
  end

  def digitize(morse_letter)
    sum = 0
    morse_letter.ljust(4, padstr=' ').split("").
      each_with_index do |e, i|
        place = 3 ** i
        sum += place * (e == "." ? 1 : (e == "-" ? 2 : 0))
      end
    sum
  end

  def random_strategy
    alphabet = ("a".."z").to_a
    81.times.map{ alphabet[rand(26)] }.join
  end
end
