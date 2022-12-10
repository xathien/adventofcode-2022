register = 1
cycle = 0
command_lengths = { "noop" => 1, "addx" => 2 }
buffer = ""

File.readlines('input').each { |line|
  command, value = line.strip.split(" ")
  command_lengths[command].times {
    buffer << ((cycle - register).abs <= 1 ? "#" : ".")
    cycle += 1
    # pp "Cycle, register, buffer: #{cycle}, #{register}", buffer
    if cycle == 40
      p buffer
      buffer = ""
      cycle = 0
    end
  }

  if command == "addx"
    register += value.to_i
  end
}