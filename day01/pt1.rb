require 'set'

max_calories = 0
calories = 0
File.readlines('input')
    .map(&:strip)
    .each do |line|
      if line.empty?
        max_calories = calories if calories > max_calories
        calories = 0
      else
        calories += line.strip.to_i
      end
    end

pp "Max? #{max_calories}"