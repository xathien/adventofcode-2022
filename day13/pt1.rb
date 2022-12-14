require 'json'

prev = nil
pair_count = 0
ordered = 0

def is_ordered?(first, second)
  pp "Comparing!", first, second
  result = if second.nil? # Comparing two lists where the second ran out of elements
    :disorder
  elsif first.is_a?(Array) && second.is_a?(Array)
    # [].zip(non_empty_array) will return empty array, frustratingly enough
    return :ordered if first.empty? && !second.empty?
    first.zip(second).each { |one, two|
      sub_ordered = is_ordered?(one, two)
      return sub_ordered unless sub_ordered == :equal
    }
    first.size < second.size ? :ordered : :equal
  elsif first.is_a?(Integer)
    if second.is_a?(Integer)
      if first < second
        :ordered
      elsif first > second
        :disorder
      else
        :equal
      end
    else
      is_ordered?([first], second)
    end
  else # Second is integer, first is list
    is_ordered?(first, [second])
  end
  pp "Result: #{result}"
  result
end

File.readlines('input').each { |line|
  line = line.strip
  next if line.empty?

  parsed = JSON.parse(line)
  if prev.nil?
    prev = parsed
  else
    pair_count += 1
    pp "====== PAIR #{pair_count} ======"
    if is_ordered?(prev, parsed) == :disorder
      pp "Disorder!"
    else
      ordered += pair_count
      pp "Ordered pair! Now is #{ordered}"
    end
    prev = nil
  end
}

pp "Ordered? #{ordered}"