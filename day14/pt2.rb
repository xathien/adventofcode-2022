require 'set'

min_x = -3000
max_x = 3000
max_y = 174
grid = Array.new(max_y + 1) { Array.new(max_x - min_x + 1){ "." } }
grid[max_y] = Array.new(max_x - min_x + 1) { "#" }
grid[0][500 - min_x] = "+"

File.readlines('input').each { |line|
  prev_x, prev_y = nil
  row = line.strip.split(" -> ").map { |coords|
    x, y = coords.split(",").map(&:to_i)
    unless prev_x.nil?
      x_range = (prev_x..x)
      x_range = x_range.step(-1) if prev_x > x
      y_range = (prev_y..y)
      y_range = y_range.step(-1) if prev_y > y

      y_range.each { |step_y|
        row = grid[step_y]
        x_range.each { |step_x|
          row[step_x - min_x] = "#"
        }
      }
    end
    prev_x = x
    prev_y = y
  }
}

done = false
start_coords = [500 - min_x, 0]
settled_count = 0
until done
  x, y = start_coords
  if settled_count % 1000 == 0
    pp "======= AFTER #{settled_count} ======="
    # grid.each { |row| p row.join }
  end
  settled = false
  done = until settled
    next_row = grid[y + 1]
    break pp "YOU DONE GOOFED UP IDJIT" if next_row.nil?

    if next_row[x] == "."
      y += 1
    elsif next_row[x-1] == "."
      x -= 1
      y += 1
    elsif next_row[x+1] == "."
      x += 1
      y += 1
    else
      grid[y][x] = "o"
      settled = true
      settled_count += 1
      break y == 0
    end
  end
end
pp "Grid 0 size #{grid[0].size}"
pp "Settled #{settled_count}"