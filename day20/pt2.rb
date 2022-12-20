class Number
  attr_reader :value, :prev
  attr_accessor :index, :succ

  def initialize(value, _index)
    @value = value
  end

  def prev=(prev)
    @prev = prev
    prev.succ = self
  end

  def move(number_size)
    travel_count = value.abs % (number_size - 1) # Fenceposting
    return if travel_count == 0

    if travel_count == 1
      succ_succ = succ.succ
      old_prev = prev
      succ.prev = old_prev
      self.prev = succ
      succ_succ.prev = self
    elsif travel_count == -1
      prev_prev = prev.prev
      old_succ = succ
      old_succ.prev = prev
      prev.prev = self
      self.prev = prev_prev
    else
      # Scan our nexts/prevs
      target = self
      new_succ = nil
      new_prev = nil
      if value < 0
        # Target will be the new succ
        travel_count.times {
          target = target.prev
        }
        new_succ = target
        new_prev = target.prev
      else
        # Target will be the new prev
        travel_count.times {
          target = target.succ
        }
        new_succ = target.succ
        new_prev = target
      end

      old_prev = prev
      old_succ = succ
      new_succ.prev = self
      self.prev = new_prev
      old_succ.prev = old_prev
    end
  end
end

@zero = nil

decryption_key = 811589153

@numbers = File.readlines('input').each_with_index.map { |line, index|
  num = Number.new(line.strip.to_i * decryption_key, index)
  @zero = num if num.value == 0
  num
}

prev = @numbers.last
@numbers.each { |number|
  number.prev = prev
  prev = number
}
number_size = @numbers.size

10.times {
  @numbers.each { |number|
    number.move(number_size)
  }
}

current = @zero
1000.times {
  current = current.succ
}
sum = current.value
pp "First number: #{current.value}"
1000.times {
  current = current.succ
}
sum += current.value
pp "Second number: #{current.value}"
1000.times {
  current = current.succ
}
sum += current.value
pp "Third number: #{current.value}"
pp "Total sum: #{sum}"
