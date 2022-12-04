require 'set'

overlapping = File.readlines('input')
    .count do |line|
      first, second = line.strip.split(",").map { |elf| Range.new(*elf.split("-").map(&:to_i)) }
      first.cover?(second) || second.cover?(first)
    end

pp "Overlap? #{overlapping}"