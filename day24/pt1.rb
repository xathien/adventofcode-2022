require 'set'
require 'fc'

grid_hash = Hash.new { |h, k| h[k] = [] }
empty_grid_hash = grid_hash.dup

row_width = 0
last_index = 0

File.readlines("input").each_with_index { |line, y|
  line.strip!
  row_width = line.size
  last_index = y
  line.chars.each_with_index { |char, x|
    next if char == "."
    coords = [x, y]
    grid_hash[coords] << char.to_sym
  }
}

row_count = last_index + 1

cycle_length = row_width.lcm(row_count)
all_grids = [grid_hash]
(cycle_length - 1).times { |start_index|
  start_grid = all_grids[start_index]
  next_grid = empty_grid_hash.dup
  all_grids << next_grid

  start_grid.each { |(x, y), directions|
    directions.each { |dir|
      target_x = x
      target_y = y
      case dir
      when :<
        target_x = (x - 1) % row_width
      when :>
        target_x = (x + 1) % row_width
      when :^
        target_y = (y - 1) % row_count
      when :v
        target_y = (y + 1) % row_count
      end

      next_grid[[target_x, target_y]] << dir
    }
  }
}

# Now to search!
target_x = row_width - 1
target_y = last_index
start_node = [0, -1, 0]

came_from = {}
g_scores = Hash.new { |h, k| h[k] = Float::INFINITY }
g_scores[start_node] = 1

moves = [[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]].freeze
visited = Set.new

queue = FastContainers::PriorityQueue.new(:min)
queue.push(start_node, row_width + last_index)
time_taken = nil
until queue.empty?
  x, y, turn = current = queue.pop
  next if visited.include?(current) # We've already visited this path
  next_turn = turn + 1

  if x == target_x && y == target_y
    time_taken = next_turn
    break
  end

  g_score = g_scores[current]
  next_g_score = g_score + 1
  next_grid = all_grids[next_turn % all_grids.size]

  # Check spaces we can move
  moves.each { |dx, dy|
    next_x = x + dx
    next_y = y + dy
    next if next_x < 0 || next_y < 0 || next_x > target_x || next_y > target_y || next_grid.key?([next_x, next_y])
    target = [next_x, next_y, next_turn]
    if next_g_score < g_scores[target]
      came_from[target] = current
      g_scores[target] = next_g_score
      distance_heuristic = next_g_score + (row_width - next_x + last_index - next_y - 1)
      queue.push(target, distance_heuristic)
    end
  }
end

pp "Total steps: #{time_taken}"