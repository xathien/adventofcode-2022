require 'set'

target_y = 2000000

beacon_x = Set.new
unbeaconed_x = Set.new

File.readlines('input').each { |line|
  s_x, s_y, b_x, b_y = line.strip.split(",").map(&:to_i)
  beacon_x << b_x if b_y == target_y
  x_distance = (b_x - s_x).abs
  y_distance = (b_y - s_y).abs
  total_distance = x_distance + y_distance
  y_distance_to_target = (target_y - s_y).abs
  pp "#{s_x}, #{s_y} => y_distance to target row #{y_distance_to_target}, total distance #{total_distance}"
  if y_distance_to_target <= total_distance
    unbeaconed_x << s_x
    x_distance_remaining = total_distance - y_distance_to_target
    pp "Adding #{s_x}, distance remaining #{x_distance_remaining}"
    (1..x_distance_remaining).each { |dx|
      unbeaconed_x << s_x - dx
      unbeaconed_x << s_x + dx
    }
  end
}

unbeaconed_x.subtract(beacon_x)
pp "Unbeaconed at #{target_y}? #{unbeaconed_x.size}"