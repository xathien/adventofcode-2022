require 'set'

@size = 22
def size
  @size
end

@size2 = size * size
voxels = Array.new(size) { Array.new(size) { Array.new(size, 0) } }

File.readlines('input').each { |line|
  x, y, z = line.strip.split(",").map(&:to_i)
  voxels[x+1][y+1][z+1] = 1
}

empty_coords_visited = Set.new

def coords(x, y, z)
  x * @size2 + y * @size + z
end

# Fill out the boundary box as "visited" so the pathfinding algorithm will terminate
(0..size).each { |dim1|
  (0..size).each { |dim2|
    # Some duplication here, but ... meh
    empty_coords_visited << coords(dim1, 0, dim2) # Front
    empty_coords_visited << coords(dim1, 21, dim2) # Back
    empty_coords_visited << coords(0, dim1, dim2) # Left
    empty_coords_visited << coords(21, dim1, dim2) # Right
    empty_coords_visited << coords(dim1, dim2, 0) # Bottom
    empty_coords_visited << coords(dim1, dim2, 21) # Top
  }
}
full_surface_area = 3454

interior_area = (1..20).sum { |x|
  col = voxels[x]
  (1..20).sum { |y|
    row = col[y]
    bottom = (1..20).sum { |z|
      cell = row[z]
      next 0 if cell == 1 || empty_coords_visited.include?(coords(x, y, z))

      # We may have found ourselves an interior node; let's go exploring
      coords_this_pocket = Set.new
      sub_area = 0
      queue = [[x, y, z]]
      failed = until queue.empty?
        sub_x, sub_y, sub_z = queue.pop
        sub_coords = coords(sub_x, sub_y, sub_z)
        next unless coords_this_pocket.add?(sub_coords) # Already visited this node in this pocket

        break true if empty_coords_visited.include?(sub_coords) # We have a path outside

        sub_col = voxels[sub_x]
        sub_row = sub_col[sub_y]
        sub_cell = sub_row[sub_z]


        # Yeah, yeah, I could make def visit_sub_coords(x, y, z) and this would be a million cleaner
        up = sub_row[sub_z - 1]
        if up == 1
          sub_area += 1 # Wall is an invalid surface area. Destroy!
        else
          queue << [sub_x, sub_y, sub_z - 1]
        end

        down = sub_row[sub_z + 1]
        if down == 1
          sub_area += 1
        else
          queue << [sub_x, sub_y, sub_z + 1]
        end

        front = sub_col[sub_y - 1][sub_z]
        if front == 1
          sub_area += 1
        else
          queue << [sub_x, sub_y - 1, sub_z]
        end

        back = sub_col[sub_y + 1][sub_z]
        if back == 1
          sub_area += 1
        else
          queue << [sub_x, sub_y + 1, sub_z]
        end

        left = voxels[sub_x - 1][sub_y][sub_z]
        if left == 1
          sub_area += 1
        else
          queue << [sub_x - 1, sub_y, sub_z]
        end

        right = voxels[sub_x + 1][sub_y][sub_z]
        if right == 1
          sub_area += 1
        else
          queue << [sub_x + 1, sub_y, sub_z]
        end
      end

      empty_coords_visited.merge(coords_this_pocket)
      failed ? 0 : sub_area
    }
  }
}

pp "Interior area? #{interior_area}"
pp "Total area? #{full_surface_area} - #{interior_area} = #{full_surface_area - interior_area}"