require 'json'

prev = nil
pair_count = 0
ordered = 0
packets = [
  [[2]],
  [[6]],
]

def compare(first, second)
  if second.nil? # Comparing two lists where the second ran out of elements
    1
  elsif first.is_a?(Array) && second.is_a?(Array)
    # [].zip(non_empty_array) will return empty array, frustratingly enough
    return -1 if first.empty? && !second.empty?
    first.zip(second).each { |one, two|
      sub_ordered = compare(one, two)
      return sub_ordered unless sub_ordered.zero?
    }
    first.size < second.size ? -1 : 0
  elsif first.is_a?(Integer)
    if second.is_a?(Integer)
      if first < second
        -1
      elsif first > second
        1
      else
        0
      end
    else
      compare([first], second)
    end
  else # Second is integer, first is list
    compare(first, [second])
  end
end

File.readlines('input').each { |line|
  line = line.strip
  next if line.empty?

  packets << JSON.parse(line)
}

packets.sort! { |first, second| compare(first, second) }
first_index = packets.find_index([[2]])
second_index = packets.find_index([[6]])
pp packets
pp "Decoded: #{(first_index + 1) * (second_index + 1)}"