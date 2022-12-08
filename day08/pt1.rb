rows = []

File.readlines('input').each { |line|
  rows << line.strip.chars.map(&:to_i)
}

visible = []
row_size = rows[0].size
col_max_heights = Array.new(row_size, -1)

rows.each_with_index { |row, row_index|
  visible << row_visible = Array.new(row_size, 0)
  row_max_height = -1
  row.each_with_index { |height, col_index|
    if height > row_max_height
      row_visible[col_index] = 1
      row_max_height = height
    end
    if height > col_max_heights[col_index]
      row_visible[col_index] = 1
      col_max_heights[col_index] = height
    end
  }
}

col_max_heights = Array.new(row_size, -1)

rows.each_with_index.reverse_each { |row, row_index|
  row_visible = visible[row_index]
  row_max_height = -1
  row.each_with_index.reverse_each { |height, col_index|
    if height > row_max_height
      row_visible[col_index] = 1
      row_max_height = height
    end
    if height > col_max_heights[col_index]
      row_visible[col_index] = 1
      col_max_heights[col_index] = height
    end
  }
}
pp "Visible? #{visible.sum(&:sum)}"