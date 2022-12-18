voxels = Array.new(22) { Array.new(22) { Array.new(22, 0) } }

File.readlines('input').each { |line|
  x, y, z = line.strip.split(",").map(&:to_i)
  voxels[x+1][y+1][z+1] = 1
}

exposed = (1..20).sum { |x_i|
  x = voxels[x_i]
  left_x = voxels[x_i - 1]
  right_x = voxels[x_i + 1]
  (1..20).sum { |y_i|
    y = x[y_i]
    front = x[y_i - 1]
    back = x[y_i + 1]
    left_y = left_x[y_i]
    right_y = right_x[y_i]
    (1..20).sum { |z_i|
      cell = y[z_i]
      next 0 unless cell == 1

      up = y[z_i - 1]
      down = y[z_i + 1]
      front_cell = front[z_i]
      back_cell = back[z_i]
      left_cell = left_y[z_i]
      right_cell = right_y[z_i]
      (1 ^ up) + (1 ^ down) + (1 ^ front_cell) + (1 ^ back_cell) + (1 ^ left_cell) + (1 ^ right_cell)
    }
  }
}

pp "Surface area? #{exposed}"