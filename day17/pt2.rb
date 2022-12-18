# 7 columns and 3 wall columns on the right
real_columns = Array.new(7) { Hash.new { |h, k| h[k] = false } }
right_walls = Array.new(3) { Hash.new { |h, k| h[k] = true } }
columns = real_columns.concat(right_walls)
column_max_heights = Array.new(7, 1)

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
current_shape = -1

check_row = [false, false, false, true, true, true, true].freeze

jets = File.read('input').strip.chars
current_jet = -1
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

patterns = {}

loop_offset = nil
loop_height_offset = nil
loop_size = nil
loop_height_gain = nil
all_loops_total = nil
height_gain_marker = nil

rock_count = 0
rocks_left = Float::INFINITY
until rocks_left <= 0
  current_shape = (current_shape + 1) % 5
  shape = shapes[current_shape]
  # Rock spawns 3 above highest point
  rock_count += 1
  rock_left = 2
  rock_bottom = max_height + 3
  loop do
    # Jet
    current_jet = (current_jet + 1) % jet_pattern_size
    jet = jets[current_jet]
    dir = jet == "<" ? -1 : 1
    new_rock_left = rock_left + dir
    rock_left = new_rock_left unless new_rock_left < 0 || new_rock_left > 6 || collision?(shape, columns, new_rock_left, rock_bottom)

    # Fall
    new_rock_bottom = rock_bottom - 1
    if collision?(shape, columns, rock_left, new_rock_bottom)
      # Settle the rock
      (0..3).each { |shape_col_i|
        shape_col = shape[shape_col_i]
        col_i = rock_left + shape_col_i
        col = columns[col_i]
        (0..3).each { |shape_row_i|
          shape_cell = shape_col[shape_row_i]
          row = rock_bottom + shape_row_i
          col[row] ||= shape_cell
          height = row + 1
          max_height = height if shape_cell && height > max_height
          column_max_heights[col_i] = height if shape_cell
        }
      }
      if rocks_left == Float::INFINITY
        check_height = max_height - 1
        shortest_column_height = column_max_heights.min
        accessible_depths = column_max_heights.map { |height| height - shortest_column_height}
        cache_key = [accessible_depths, current_shape, current_jet]
        cached_count, cached_height = patterns[cache_key]
        if cached_count
          loop_offset = cached_count
          loop_size = rock_count - cached_count
          loop_height_offset = cached_height
          loop_height_gain = max_height - cached_height
          target_iterations = 1_000_000_000_000 - loop_offset
          full_loop_count = target_iterations / loop_size
          all_loops_total = full_loop_count * loop_height_gain
          rocks_left = target_iterations % loop_size
          height_gain_marker = max_height
        else
          patterns[cache_key] = [rock_count, max_height]
        end
      else
        rocks_left -= 1
      end

      # Next rock!
      break
    else
      rock_bottom = new_rock_bottom
    end
    # Else keep dropping this rock
  end
end

final_loop_gain = max_height - height_gain_marker
final_height = loop_height_offset + all_loops_total + final_loop_gain - 1
pp "FINAL HEIGHT: #{final_height}"
