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

# Just pretend we started by opening the first valve
state_queue = openable_valves.map { |name|
  {
    paths: [["AA"], ["AA"]],
    valves_left: openable_valves,
    pressure_rate: 0,
    released_pressure: 0,
    targets: ["AA", "AA"],
    minutes_passed: 0,
    travel_times: [0, 0]
  }
}

max_pressure = 0
max_time = 26
states_checked = 0

until state_queue.empty?
  state = state_queue.pop
  valves_left = state[:valves_left]
  pressure_rate = state[:pressure_rate]
  released_pressure = state[:released_pressure]
  minutes_passed = state[:minutes_passed]
  my_time, el_time = state[:travel_times]
  my_target, el_target = state[:targets]

  if minutes_passed >= max_time
    states_checked += 1
    pp "#{states_checked} potentials found; #{state_queue.size} in the queue, #{max_pressure} best so far" if states_checked % 100000 == 0
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
    pp "#{states_checked} potentials found; #{state_queue.size} in the queue" if states_checked % 100000 == 0
    # Circuit break; everything's open, just multiply and be done so we can spend our last few minutes picking our nose
    released_pressure += (max_time - minutes_passed) * pressure_rate +
      (max_time - minutes_passed - my_time) * nodes[my_target].rate +
      (max_time - minutes_passed - el_time) * nodes[el_target].rate
    if released_pressure > max_pressure
      max_pressure = released_pressure
      max_state = state
    end

    next
  end

  my_path, el_path = state[:paths]
  if my_time == 0
     # I need to pick a new destination
    node = nodes[my_target]
    new_pressure_rate = pressure_rate + node.rate
    valves_left.each { |next_name|
      time_distance = node.distances[next_name] + 1
      new_state = {
        paths: [my_path + [next_name], el_path],
        valves_left: valves_left - [next_name],
        pressure_rate: new_pressure_rate, # I just opened this valve
        released_pressure: released_pressure,
        targets: [next_name, el_target],
        minutes_passed: minutes_passed, # No time increment yet
        travel_times: [time_distance, el_time],
      }
      state_queue << new_state
    }
  elsif el_time == 0
    # Elephant just needs to pick a new destination
    node = nodes[el_target]
    new_pressure_rate = pressure_rate + node.rate
    valves_left.each { |next_name|
      time_distance = node.distances[next_name] + 1
      new_state = {
        paths: [my_path, el_path + [next_name]],
        valves_left: valves_left - [next_name],
        pressure_rate: new_pressure_rate, # El just opened this valve
        released_pressure: released_pressure,
        targets: [my_target, next_name],
        minutes_passed: minutes_passed,
        travel_times: [my_time, time_distance],
      }
      state_queue << new_state
    }
  else
    # Both en route; figure out who gets there first
    shorter_time = [my_time, el_time].min
    new_state = {
      paths: state[:paths],
      valves_left: valves_left,
      pressure_rate: pressure_rate,
      released_pressure: released_pressure + pressure_rate * shorter_time,
      targets: [my_target, el_target],
      minutes_passed: minutes_passed + shorter_time,
      travel_times: [my_time - shorter_time, el_time - shorter_time],
    }
    state_queue << new_state
  end
end

pp "Max pressure? #{max_pressure}"
pp "Max state? #{max_state}"