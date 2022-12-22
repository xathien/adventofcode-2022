dir_change = {
  r: { L: :u, R: :d },
  u: { L: :l, R: :r },
  l: { L: :d, R: :u },
  d: { L: :r, R: :l },
}

row_offsets = []
row_widths = []
row_ends = []
offset_regex = /\.|#/
rows = File.readlines("input").map { |line|
  offset = line.index(offset_regex)
  row_offsets << offset
  row = line.strip.chars.map { |char| char == "." ? true : false }
  row_widths << row.size
  row_ends << row.size + offset
  row
}

row_count = rows.size

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
    row = rows[y]
    count.times {
      case direction
      when :r
        new_x = (x + 1) % row_widths[y]
        break unless row[new_x]
        x = new_x
      when :l
        new_x = (x - 1) % row_widths[y] # This works for negative numbers; convenient
        break unless row[new_x]
        x = new_x
      when :u
        new_y = (y - 1) % row_count
        true_x = x + row_offsets[y]
        new_x = true_x - row_offsets[new_y]
        while new_x < 0 || new_x > row_widths[new_y]
          new_y = (new_y - 1) % row_count
          new_x = true_x - row_offsets[new_y]
        end
        target_row = rows[new_y]
        break unless target_row[new_x]
        x = new_x
        y = new_y
        row = target_row
      when :d
        new_y = (y + 1) % row_count
        true_x = x + row_offsets[y]
        new_x = true_x - row_offsets[new_y]
        while new_x < 0 || new_x > row_widths[new_y]
          new_y = (new_y + 1) % row_count
          new_x = true_x - row_offsets[new_y]
        end
        target_row = rows[new_y]
        break unless target_row[new_x]
        x = new_x
        y = new_y
        row = target_row
      end
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
