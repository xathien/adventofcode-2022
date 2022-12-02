require 'set'

scores = { rock: 1, paper: 2, scissors: 3 }
letters = { "A" => :rock, "B" => :paper, "C" => :scissors, "X" => :rock, "Y" => :paper, "Z" => :scissors }
outcomes = {
  rock: { rock: 3, paper: 6, scissors: 0 },
  paper: { rock: 0, paper: 3, scissors: 6 },
  scissors: { rock: 6, paper: 0, scissors: 3 }
}

score = 0
File.readlines('input')
    .each do |line|
      play, response = line.strip.split(" ").map { |letter| letters[letter] }
      score += scores[response] + outcomes[play][response]
    end

pp "Score? #{score}"