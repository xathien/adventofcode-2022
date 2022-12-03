require 'set'

letters = ('a'..'z').to_a + ('A'..'Z').to_a
values = Hash[letters.zip(1..letters.size)]

score = File.readlines('input')
    .sum do |line|
      line = line.strip
      c1, c2 = line.chars.each_slice(line.length / 2).map { |chunk| Set.new(chunk) }
      common_letter = c1.intersection(c2).first
      values[common_letter]
    end

pp "Score? #{score}"