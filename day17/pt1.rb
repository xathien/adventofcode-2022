# 7 columns and 3 wall columns on the right
real_columns = Array.new(7) { Hash.new { |h, k| h[k] = false } }
right_walls = Array.new(3) { Hash.new { |h, k| h[k] = true } }
columns = real_columns.concat(right_walls)

# Set the floor because I'm lazy
real_columns.each { |col| col[0] = true }

# Just remember to reset this after to avoid the inevitable off-by-one
max_height = 1
shapes = [
  [
    [true, false, false, false],
    [true, false, false, false],
    [true, false, false, false],
    [true, false, false, false],
  ],
  [
    [false, true,  false, false],
    [true,  true,  true,  false],
    [false, true,  false, false],
    [false, false, false, false],
  ],
  [
    [true,  false, false, false],
    [true,  false, false, false],
    [true,  true,  true,  false],
    [false, false, false, false],
  ],
  [
    [true,  true,  true,  true],
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false],
  ],
  [
    [true,  true,  false, false],
    [true,  true,  false, false],
    [false, false, false, false],
    [false, false, false, false],
  ],
]
shape_enum = shapes.cycle

jets = File.read('input').strip.chars
jet_enum = jets.cycle
jet_pattern_size = jets.size

def collision?(shape, columns, rock_left, rock_bottom)
  return true if rock_left < 0 || rock_left > 6
  (0..3).any? { |shape_col_i|
    shape_col = shape[shape_col_i]
    col = columns[rock_left + shape_col_i]
    (0..3).any? { |shape_row_i|
      shape_cell = shape_col[shape_row_i]
      cell = col[rock_bottom + shape_row_i]
      shape_cell & cell
    }
  }
end

def print_board(columns, max_height)
  (max_height + 3..1).step(-1).each { |row|
    line = "|"
    (0..6).each { |col|
      line << (columns[col][row] ? "#" : ".")
    }
    line << "|"
    p line
  }
  p "+-------+"
end

2022.times { |time|
  shape = shape_enum.next
  # Rock spawns 3 above highest point
  rock_left = 2
  rock_bottom = max_height + 3
  loop do
    # Jet
    jet = jet_enum.next
    dir = jet == "<" ? -1 : 1
    new_rock_left = rock_left + dir
    rock_left = new_rock_left unless collision?(shape, columns, new_rock_left, rock_bottom)

    # Fall
    new_rock_bottom = rock_bottom - 1
    if collision?(shape, columns, rock_left, new_rock_bottom)
      # Settle the rock
      (0..3).each { |shape_col_i|
        shape_col = shape[shape_col_i]
        col = columns[rock_left + shape_col_i]
        (0..3).each { |shape_row_i|
          shape_cell = shape_col[shape_row_i]
          row = rock_bottom + shape_row_i
          col[row] ||= shape_cell
          height = row + 1
          max_height = height if shape_cell && height > max_height
        }
      }

      # Next rock!
      break
    else
      rock_bottom = new_rock_bottom
    end
    # Else keep dropping this rock
  end

  # pp "====== AFTER ROCK #{time} ======"
  # print_board(columns, max_height)
}
pp "Max height! #{max_height - 1}"