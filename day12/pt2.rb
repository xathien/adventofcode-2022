require 'set'

heights = ('a'..'z').each_with_index.to_h
heights["S"] = heights['a']
heights["E"] = heights['z']

start_coords = nil
end_coords = nil
@grid = []
@start_positions = []

File.readlines('input').each { |line|
  row = line.strip.chars.each_with_index.map { |char, index|
    coords = [index, @grid.size]
    if char == "E"
      end_coords = coords
    elsif char == "a" && index == 0
      @start_positions << coords
    end
    heights[char]
  }
  @grid << row
}

def connected_coords(coords)
  x, y = coords
  row = @grid[y]
  height = row[x]
  connected = []
  # Up
  connected << [x, y - 1] if y > 0 && height >= @grid[y - 1][x] - 1
  # Down
  connected << [x, y + 1] if y < @grid.size - 1 && height >= @grid[y + 1][x] - 1
  # Left
  connected << [x - 1, y] if x > 0 && height >= row[x - 1] - 1
  # Right
  connected << [x + 1, y] if x < row.size - 1 && height >= row[x + 1] - 1

  connected
end

shortest = @start_positions.map { |start_coords|
  distance = { start_coords => 0 }
  previous = {}
  queue = Set.new
  queue << start_coords

  while !queue.empty?
    current_coords = queue.min_by { |coords| distance[coords] }

    next_distance = distance[current_coords] + 1
    queue.delete(current_coords)

    connected_coords(current_coords).each { |next_coords|
      if next_distance < (distance[next_coords] || Float::INFINITY)
        distance[next_coords] = next_distance
        previous[next_coords] = current_coords
        queue << next_coords
      end
    }
  end

  path = []
  current = end_coords
  until current == start_coords || current.nil?
    path << current
    current = previous[current]
  end

  next 9001 if current.nil?

  path.size
}.min

pp "Distance? #{shortest}"