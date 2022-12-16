require 'set'

class Node
  attr_reader :rate, :raw_links, :compressed
  attr_accessor :distances

  def initialize(rate, raw_links)
    @rate = rate
    @raw_links = raw_links
    @compressed = false
  end

  def compress_links(nodes, openable_valves, whoami)
    distances = openable_valves.map { |name|
      [name, Float::INFINITY]
    }.to_h
    distances[whoami] = 0 if rate > 0
    initial_visited = Set.new([whoami])
    queue = @raw_links.map { |raw_link|
      [raw_link, initial_visited]
    }
    until queue.empty?
      name, visited = queue.pop
      distance = visited.size
      best_distance = distances[name]
      distances[name] = distance if best_distance && distance < best_distance
      new_visited = visited + [name]
      node = nodes[name]
      if node.compressed
        node.distances.each { |target, other_distance|
          combined_distance = distance + other_distance
          best_distance = distances[target]
          distances[target] = combined_distance if combined_distance < best_distance
        }
      else
        next_links = (node.raw_links - new_visited).map { |next_link|
          [next_link, new_visited]
        }
        queue.concat(next_links)
      end
    end
    @distances = distances
    @compressed = true
  end
end

nodes = {}
openable_valves = []

File.readlines('input').each { |line|
  row = line.strip.split(",")
  name, rate = row
  rate = rate.to_i
  links = row[2..].to_set
  nodes[name] = Node.new(rate, links)
  openable_valves << name if rate > 0
}

nodes.each { |name, node|
  node.compress_links(nodes, openable_valves, name)
}

start_node = nodes["AA"]

# Just pretend we started by opening the first valve
state_queue = openable_valves.map { |name|
  {
    path: [name],
    valves_left: openable_valves - [name],
    pressure_rate: nodes[name].rate,
    released_pressure: 0,
    location: name,
    minutes_passed: start_node.distances[name] + 1,
  }
  # 2134 best
}

limiter = 21
max_time = 26
states_checked = 0
final_states = {}

until state_queue.empty?
  state = state_queue.pop
  valves_left = state[:valves_left]
  pressure_rate = state[:pressure_rate]
  released_pressure = state[:released_pressure]
  minutes_passed = state[:minutes_passed]

  if minutes_passed >= limiter
    states_checked += 1

    # Roll forward the pressure to 26
    last_added = state[:path].pop
    pressure_rate -= nodes[last_added].rate
    released_pressure += (max_time - minutes_passed) * pressure_rate
    path = state[:path]
    final_states[path] = released_pressure
    next
  end

  path = state[:path]
  node = nodes[state[:location]]
  valves_left.each { |next_name|
    # Go to next valve and open it
    time_distance = node.distances[next_name] + 1
    next_rate = nodes[next_name].rate
    new_state = {
      path: path + [next_name],
      valves_left: valves_left - [next_name],
      pressure_rate: pressure_rate + next_rate,
      released_pressure: released_pressure + pressure_rate * time_distance,
      location: next_name,
      minutes_passed: minutes_passed + time_distance,
    }
    state_queue << new_state
  }
end

# Now just combine all the possibilities
pp "What's the size of this thing NOW? #{final_states.size}"
pp "Final states: #{final_states}"
pp "Let's start combining!"
max_pressure = 0
max_pressure_combo = nil
checked_combinations = 0
keys = final_states.keys
last_index = keys.size - 1
keys.each_with_index { |first_path_set, index|
  first_pressure = final_states[first_path_set]
  (index+1..last_index).each { |second_index|
    second_path_set = keys[second_index]
    second_pressure = final_states[second_path_set]
    checked_combinations += 1
    pp "===== CHECKING COMBINATION #{checked_combinations} ====" if checked_combinations % 1000000 == 0
    next unless first_path_set.intersection(second_path_set).empty?
    combined_pressure = first_pressure + second_pressure
    max_pressure = combined_pressure if combined_pressure > max_pressure
    max_pressure_combo = [first_path_set, second_path_set]
  }
}
pp "Max pressure? #{max_pressure}"
pp "Combo #{max_pressure_combo}"