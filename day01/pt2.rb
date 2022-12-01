require 'set'

calories = 0
elves = []
File.readlines('input')
    .map(&:strip)
    .each do |line|
      if line.empty?
        elves << calories
        calories = 0
      else
        calories += line.strip.to_i
      end
    end

elves.sort! { |x,y| y <=> x }

pp "Max? #{elves.first(3).sum}"