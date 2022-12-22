dir_change = {
  r: { L: :u, R: :d },
  u: { L: :l, R: :r },
  l: { L: :d, R: :u },
  d: { L: :r, R: :l },
}

face_size = 50
faces = []
face = []
File.readlines("input_cube").each_with_index.each { |line, index|
  row = line.strip.chars.map { |char| char == "." ? true : false }
  face << row
  if (index + 1) % 50 == 0
    faces << face
    face = []
  end
}

col_offsets = {
  0 => 50,
  1 => 100,
  2 => 50,
  3 => 0,
  4 => 50,
  5 => 0,
}

row_offsets = {
  0 => 0,
  1 => 0,
  2 => 50,
  3 => 100,
  4 => 100,
  5 => 150,
}

x = 0
y = 0
face = 0
direction = :r
direction_regex = /(\d+|L|R)/
File.read("input_directions").strip.scan(direction_regex) { |step|
  step = step[0]
  case step
  when "L", "R"
    direction = dir_change[direction][step.to_sym]
  else
    count = step.to_i
    count.times {
      new_x = x
      new_y = y
      new_direction = direction
      new_face = face
      case direction
      when :r
        new_x += 1
        if new_x == 50
          case face
          when 0
            new_face = 1
            new_x = 0
          when 1
            new_face = 4
            new_x = 49
            new_y = 49 - y
            new_direction = :l
          when 2
            new_face = 1
            new_y = 49
            new_x = y
            new_direction = :u
          when 3
            new_face = 4
            new_x = 0
          when 4
            new_face = 1
            new_x = 49
            new_y = 49 - y
            new_direction = :l
          when 5
            new_face = 4
            new_x = y
            new_y = 49
            new_direction = :u
          end
        end
      when :l
        new_x -= 1
        if new_x < 0
          case face
          when 0
            new_face = 3
            new_x = 0
            new_y = 49 -y
            new_direction = :r
          when 1
            new_face = 0
            new_x = 49
          when 2
            new_face = 3
            new_y = 0
            new_x = y
            new_direction = :d
          when 3
            new_face = 0
            new_x = 0
            new_y = 49 - y
            new_direction = :r
          when 4
            new_face = 3
            new_x = 49
          when 5
            new_face = 0
            new_x = y
            new_y = 0
            new_direction = :d
          end
        end
      when :u
        new_y -= 1
        if new_y < 0
          case face
          when 0
            new_face = 5
            new_x = 0
            new_y = x
            new_direction = :r
          when 1
            new_face = 5
            new_y = 49
          when 2
            new_face = 0
            new_y = 49
          when 3
            new_face = 2
            new_x = 0
            new_y = x
            new_direction = :r
          when 4
            new_face = 2
            new_y = 49
          when 5
            new_face = 3
            new_y = 49
          end
        end
      when :d
        new_y += 1
        if new_y == 50
          case face
          when 0
            new_face = 2
            new_y = 0
          when 1
            new_face = 2
            new_x = 49
            new_y = x
            new_direction = :l
          when 2
            new_face = 4
            new_y = 0
          when 3
            new_face = 5
            new_y = 0
          when 4
            new_face = 5
            new_x = 49
            new_y = x
            new_direction = :l
          when 5
            new_face = 1
            new_y = 0
          end
        end
      end
      break unless faces[new_face][new_y][new_x]
      x = new_x
      y = new_y
      direction = new_direction
      face = new_face
    }
  end
}

dir_vals = {
  r: 0,
  u: 3,
  l: 2,
  d: 1,
}
col_val = x + col_offsets[face] + 1
row_val = y + row_offsets[face] + 1
dir_val = dir_vals[direction]
pp "Actual coords: Face #{face} => #{x}, #{y}, #{direction}"
pp "Coords: #{col_val}, #{row_val}, #{dir_val}"
pp "Password: #{1000 * row_val + 4 * col_val + dir_val}"
