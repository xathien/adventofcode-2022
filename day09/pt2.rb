require 'set'

rope_coords = Array.new(10) { [0, 0]}
head = rope_coords[0]
visited_coords = Set.new([[0, 0]])

File.readlines('input').each { |line|
  direction, distance = line.strip.split(" ")
  distance = distance.to_i
  pp "Moving Head #{direction}, #{distance}"
  distance.times {
    case direction
    when "D"
      head[1] -= 1
    when "U"
      head[1] += 1
    when "L"
      head[0] -= 1
    when "R"
      head[0] += 1
    end
    pp "Head now at #{head}"

    rope_coords.each_with_index.drop(1).each { |coord, index|
      prev_coord = rope_coords[index - 1]
      x_distance = (prev_coord[0] - coord[0]).abs
      y_distance = (prev_coord[1] - coord[1]).abs
      if x_distance > 1 || y_distance > 1
        x_dir = prev_coord[0] <=> coord[0]
        y_dir = prev_coord[1] <=> coord[1]
        coord[0] += x_dir
        coord[1] += y_dir
        if index == 9
          visited_coords << [coord[0], coord[1]]
          pp "Tail moved #{x_dir}, #{y_dir} to #{coord[0]}, #{coord[1]} - size now #{visited_coords.size}"
        end
      end
    }
  }
}

pp "Coords visited? #{visited_coords.size}"