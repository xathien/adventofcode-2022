register = 1
cycle = -20
strengths = 0
command_lengths = { "noop" => 1, "addx" => 2 }

File.readlines('input').each { |line|
  command, value = line.strip.split(" ")
  (1..command_lengths[command]).times {
    cycle += 1
    if cycle % 40 == 0
      cycle_multiplier = 20 + cycle
      strengths += cycle_multiplier * register
    end
  }

  if command == "addx"
    register += value.to_i
  end
}

pp "Strengths? #{strengths}"