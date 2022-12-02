require 'set'

scores = { rock: 1, paper: 2, scissors: 3 }
letters = { "A" => :rock, "B" => :paper, "C" => :scissors, "X" => :lose, "Y" => :draw, "Z" => :win }
outcomes = {
  rock: { lose: 3, draw: 4, win: 8 },
  paper: { lose: 1, draw: 5, win: 9 },
  scissors: { lose: 2, draw: 6, win: 7 }
}

score = 0
File.readlines('input')
    .each do |line|
      play, response = line.strip.split(" ").map { |letter| letters[letter] }
      score += outcomes[play][response]
    end

pp "Score? #{score}"