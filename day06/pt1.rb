require "set"

current = %w(d j h)

File.open('input').each_char.each_with_index { |char, index|
  current << char
  pp "Char #{char}, idx #{index}, current #{current}"
  break pp "Index? #{index}" if current.to_set.size == 4
  current.shift
}