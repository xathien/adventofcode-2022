require "set"

current = %w(d j h j v j g g d z z n l)

File.open('input').each_char.each_with_index { |char, index|
  current << char
  pp "Char #{char}, idx #{index}, current #{current}"
  break pp "Index? #{index + 14}" if current.to_set.size == 14
  current.shift
}