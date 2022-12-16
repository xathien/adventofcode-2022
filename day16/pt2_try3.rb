require 'set'

nodes = {}
openable_valves = []
@node_numbers = {}
def node_numbers
  @node_numbers
end

@id_seq = -1
def id(node_name)
  node_numbers[node_name] ||= (@id_seq += 1)
end

flow_rates = Array.new(60)
graph = Array.new(60) { Array.new(60, Float::INFINITY) }

File.readlines('input').each { |line|
  row = line.strip.split(",")
  name, rate = row
  rate = rate.to_i
  id = id(name)
  openable_valves << id if rate > 0
  flow_rates[id] = rate
  graph_node = graph[id]
  graph_node[id] = 0
  row[2..].each { |link|
    link_id = id(link)
    graph_node[link_id] = 1
  }
}

# Calculate all distances between all nodes
(0...graph.size).each { |i|
  (0...graph.size).each { |j|
    graph_node = graph[j]
    (0...graph.size).each { |k|
      adj_distance = graph_node[i] + graph[i][k]
      graph_node[k] = adj_distance if adj_distance < graph_node[k]
    }
  }
}

start_node = graph[id("AA")]
max_time = 26
best_scores = Hash.new { |h, k| h[k] = -1 }

# Valve index, pressure so far, time left, valves opened (bit-string)
state_queue = openable_valves.each_with_index.map { |node_id, valve_index|
  initial_distance = start_node[node_id] + 1
  time_left = max_time - initial_distance
  initial_pressure = flow_rates[node_id] * time_left
  valve_bit_pos = 1 << valve_index
  best_scores[[valve_index, valve_bit_pos]] = initial_pressure
  [valve_index, initial_pressure, time_left, valve_bit_pos]
}

until state_queue.empty?
  valve_index, released_pressure, time_left, valves_opened = state_queue.pop
  graph_node = graph[openable_valves[valve_index]]
  openable_valves.each_with_index { |next_valve_id, next_valve_index|
    next_valve_bit_pos = 1 << next_valve_index
    next unless valves_opened & next_valve_bit_pos == 0 # Already been to this valve

    distance = graph_node[next_valve_id] + 1 # Get there and open it
    next unless distance <= time_left

    new_time_left = time_left - distance
    new_released_pressure = released_pressure + flow_rates[next_valve_id] * new_time_left
    new_valves_opened = valves_opened | next_valve_bit_pos
    score_key = [next_valve_index, new_valves_opened]
    next unless best_scores[score_key] < new_released_pressure

    best_scores[score_key] = new_released_pressure
    state_queue << [next_valve_index, new_released_pressure, new_time_left, new_valves_opened]
  }
end

permutation_count = 1 << openable_valves.size
permutations = Array.new(permutation_count, 0)
best_scores.each { |(_, valves_opened), released_pressure|
  permutations[valves_opened] = released_pressure if released_pressure > permutations[valves_opened]
}

max_combo_pressure = 0
all_valves_open = permutation_count - 1
(0..all_valves_open).each { |my_permutation_base|
  elephant_permutation = all_valves_open ^ my_permutation_base
  elephant_pressure = permutations[elephant_permutation]
  max_combo_pressure = elephant_pressure if elephant_pressure > max_combo_pressure
  my_permutation = my_permutation_base
  while my_permutation > 0
    combo_pressure = elephant_pressure + permutations[my_permutation]
    max_combo_pressure = combo_pressure if combo_pressure > max_combo_pressure
    my_permutation = (my_permutation - 1) & my_permutation_base # Some duplicate work here to bitstring-iterate to zero, but should be cheap
  end
}

pp "Max pressure? #{max_combo_pressure}"