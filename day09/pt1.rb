require 'set'

head_x = 0
head_y = 0
tail_x = 0
tail_y = 0
visited_coords = Set.new([[tail_x, tail_y]])

File.readlines('input').each { |line|
  direction, distance = line.strip.split(" ")
  distance = distance.to_i
  pp "Moving Head #{direction}, #{distance}"
  distance.times {
    case direction
    when "D"
      head_y -= 1
    when "U"
      head_y += 1
    when "L"
      head_x -= 1
    when "R"
      head_x += 1
    end
    pp "Head now at #{head_x}, #{head_y} <=> [#{head_x - tail_x}, #{head_y - tail_y}]}"

    tail_x_distance = (head_x - tail_x).abs
    tail_y_distance = (head_y - tail_y).abs
    if tail_x_distance > 1 || tail_y_distance > 1
      tail_x_dir = head_x <=> tail_x
      tail_y_dir = head_y <=> tail_y
      tail_x += tail_x_dir
      tail_y += tail_y_dir
      visited_coords << [tail_x, tail_y]
      pp "Tail moved #{tail_x_dir}, #{tail_y_dir} to #{tail_x}, #{tail_y} - size now #{visited_coords.size}"
    end
  }
}

pp "Coords visited? #{visited_coords.size}"