require 'set'

min = 0
max = 4000000
search_range = (min..max)

beacon_x = Set.new
unbeaconed_x = Set.new

sensors = File.readlines('input').map { |line|
  s_x, s_y, b_x, b_y = line.strip.split(",").map(&:to_i)
  range = (b_x - s_x).abs + (b_y - s_y).abs
  [s_x, s_y, range]
}
sensors.sort! { |a, b| a[0] <=> b[0] }

y = 0
x = 0
loop do
  start_x = x
  sensors.each { |s_x, s_y, range|
    next if x >= max
    # Check if X is covered by this sensor
    x_distance = (x - s_x).abs
    y_distance = (y - s_y).abs
    distance = x_distance + y_distance
    if distance <= range # X, Y is covered
      x = s_x + (range - y_distance) + 1
    end
  }
  break if x == start_x # Didn't move
  if x >= max
    x = 0
    y += 1
  end
end

pp "Coords: #{[x, y]} => #{x * 4000000 + y}"