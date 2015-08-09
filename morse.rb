class Morse
  WORD_DELIMITER = "   "
  LETTER_DELIMITER = " "
  MAP = {
    a: ".-",
    b: "-...",
    c: "-.-.",
    d: "-..",
    e: ".",
    f: "..-.",
    g: "--.",
    h: "....",
    i: "..",
    j: ".---",
    k: "-.-",
    l: "._..",
    m: "--",
    n: "-.",
    o: "---",
    p: ".--.",
    q: "--.-",
    r: ".-.",
    s: "...",
    t: "-",
    u: "..-",
    v: "...-",
    w: ".--",
    x: "-..-",
    y: "-.--",
    z: "--.."
    }

  def self.tap_out(string)
    words = string.split(" ")
    words.map do |word|
           word.split("").map{|letter| MAP[letter.downcase.to_sym] }.join(LETTER_DELIMITER)
         end.join(WORD_DELIMITER)
  end
end
