dir_change = {
  r: { L: :u, R: :d },
  u: { L: :l, R: :r },
  l: { L: :d, R: :u },
  d: { L: :r, R: :l },
}

row_offsets = []
row_widths = []
offset_regex = /\.|#/
rows = File.readlines("input").map { |line|
  offset = line.index(offset_regex)
  row_offsets << offset
  row = line.strip.chars.map { |char| char == "." ? true : false }
  row_widths << row.size
  row
}

row_count = rows.size


face_size = 50

x = 0
y = 0
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
      case direction
      when :r
        new_x = x + 1
        new_y = y
        new_direction = direction
        if new_x == row_widths[y]
          if y < 50 # 1r => 4r, 180
            new_y = 149 - y
            new_x = x
            new_direction = :l
          elsif y < 100 # 3r => 1d, -90
            new_y = 49
            new_x = y
            new_direction = :u
          elsif y < 150 # 4r => 1r, 180
            new_x = x
            new_y = 149 - y
            new_direction = :l
          else # 6r => 4d, -90
            new_y = 149
            new_x = y - 100
            new_direction = :u
          end
        end
      when :l
        new_x = x - 1
        new_y = y
        new_direction = direction
        if new_x < 0
          if y < 50 # 2l => 5l, 180
            new_y = 149 - y
            new_x = x
            new_direction = :r
          elsif y < 100 # 3l => 5u, -90
            new_y = 100
            new_x = y - 50
            new_direction = :d
          elsif y < 150 # 5l => 2l, 180
            new_y = 149 - y
            new_x = x
            new_direction = :r
          else # 6l => 2u, -90
            new_y = 0
            new_x = y - 150
            new_direction = :d
          end
        end
      when :u
        new_x = x
        new_y = y - 1
        new_direction = direction
        if new_y < 0 || (new_y == 99 && row_offsets[y] < 50)
          if new_y == 99 # 5u => 3l, 90
            new_y = 50 + x
            new_x = 0
            new_direction = :r
          elsif x < 50 # 2u => 6l, 90
            new_y = 150 + x
            new_x = 0
            new_direction = :r
          else # 1u => 6d, 0
            new_y = 199
            new_x = x - 50
            new_direction = :u
          end
        end
      when :d
        new_x = x
        new_y = y + 1
        new_direction = direction
        if new_y == 200
            new_y = 0
            new_x = x + 50
            new_direction = :d
        elsif new_y == 150 && x >= 50
            new_y = 100 + x
            new_x = 49
            new_direction = :l
        elsif new_y == 50 && x >= 50
            new_y = x
            new_x = 49
            new_direction = :l
        end
      end
      break unless rows[new_y][new_x]
      x = new_x
      y = new_y
      direction = new_direction
    }
  end
}

dir_vals = {
  r: 0,
  u: 3,
  l: 2,
  d: 1,
}
col_val = x + row_offsets[y] + 1
row_val = y + 1
dir_val = dir_vals[direction]
pp "Coords: #{col_val}, #{row_val}, #{direction}"
pp "Password: #{1000 * row_val + 4 * col_val + dir_val}"
