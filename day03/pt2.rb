require 'set'

letters = ('a'..'z').to_a + ('A'..'Z').to_a
values = Hash[letters.zip(1..letters.size)]

score = File.readlines('input')
    .each_slice(3)
    .sum do |group|
      set1, set2, set3 = group.map { |line| line = Set.new(line.strip.chars) }
      common_letter = set1.intersection(set2).intersection(set3).first
      values[common_letter]
    end

pp "Score? #{score}"