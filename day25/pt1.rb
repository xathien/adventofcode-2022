sum = File.readlines("input").sum { |line|
  number = 0
  line.strip.chars.reverse.each_with_index { |char, digit|
    case char
    when "="
      number += -2 * (5 ** digit)
    when "-"
      number += -1 * (5 ** digit)
    when "1"
      number += 5 ** digit
    when "2"
      number += 2 * (5 ** digit)
    end
  }
  number
}

pp "Sum #{sum}"

based = sum.to_s(5)
offset = ("2" * based.size).to_i(5)
mangled = sum + offset
mangled_string = mangled.to_s(5)
if mangled_string.size > based.size
  mangled += 2 * (5 ** based.size)
  mangled_string = mangled.to_s(5)
end
snafu = mangled_string.chars.map { |char|
  case char
  when "4"
    "2"
  when "3"
    "1"
  when "2"
    "0"
  when "1"
    "-"
  when "0"
    "="
  end
  }.join
pp "Snafu #{snafu}"