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

File.readlines('input_test').each { |line|
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
}

max_pressure = 0
max_state = nil
max_time = 11
states_checked = 0

until state_queue.empty?
  state = state_queue.pop
  valves_left = state[:valves_left]
  pressure_rate = state[:pressure_rate]
  released_pressure = state[:released_pressure]
  minutes_passed = state[:minutes_passed]

  if minutes_passed >= max_time
    states_checked += 1
    # Roll back the pressure to what it was at 30
    released_pressure -= (minutes_passed - max_time) * pressure_rate
    if released_pressure > max_pressure
      max_pressure = released_pressure
      max_state = state
    end

    next
  end

  if valves_left.empty?
    states_checked += 1
    # Circuit break; everything's open, just multiply and be done so we can spend our last few minutes picking our nose
    released_pressure += (max_time - minutes_passed) * pressure_rate
    if released_pressure > max_pressure
      max_pressure = released_pressure
      max_state = state
    end

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

pp "Max pressure? #{max_pressure}"
pp "Max path? #{max_state}"