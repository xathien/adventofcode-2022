rows = []

File.readlines('input').each { |line|
  rows << line.strip.chars.map(&:to_i)
}

max_score = 0
row_max_index = rows.size - 1
col_max_index = rows[0].size - 1
(1..row_max_index).each { |row_index|
  row = rows[row_index]
  (1..col_max_index).each { |col_index|
    height = row[col_index]

    target = (row_index == 16 && col_index == 60)
    # Up
    score = (row_index - 1).downto(0).reduce(0) { |count, row2_index|
      seen_height = rows[row2_index][col_index]
      break count + 1 if seen_height >= height
      count + 1
    }

    # Down
    score *= (row_index + 1..row_max_index).reduce(0) { |count, row2_index|
      seen_height = rows[row2_index][col_index]
      break count + 1 if seen_height >= height
      count + 1
    }

    # Left
    score *= (col_index - 1).downto(0).reduce(0) { |count, col2_index|
      seen_height = row[col2_index]
      break count + 1 if seen_height >= height
      count + 1
    }

    # Right
    score *= (col_index + 1..col_max_index).reduce(0) { |count, col2_index|
      seen_height = row[col2_index]
      break count + 1 if seen_height >= height
      count + 1
    }

    max_score = score if score > max_score
  }
}
pp "Max? #{max_score}"