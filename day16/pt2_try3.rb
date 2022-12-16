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
  openable_valves << id if rate > 0 || name == "AA"
  flow_rates[id] = rate
  graph_node = graph[id]
  graph_node[id] = 0
  links = row[2..].each { |link|
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

start_valve_index = openable_valves.index(id("AA"))
max_time = 26
best_scores = Hash.new { |h, k| h[k] = -1 }

# Valve index, pressure so far, time left, valves opened (bit-string)
state_queue = [[start_valve_index, 0, max_time, 0]]

until state_queue.empty?
  valve_index, released_pressure, time_left, valves_opened = state_queue.shift
  bit_pos = 1 << valve_index
  node_index = openable_valves[valve_index]
  # Haven't opened this valve and still have time to open it
  if (valves_opened & bit_pos) == 0 && time_left >= 1
    new_valves_opened = valves_opened | bit_pos # Mark opened
    new_time_left = time_left - 1
    new_released_pressure = released_pressure + flow_rates[node_index] * new_time_left
    score_key = [valve_index, new_valves_opened, new_time_left]
    if best_scores[score_key] < new_released_pressure
      best_scores[score_key] = new_released_pressure
      state_queue << [valve_index, new_released_pressure, new_time_left, new_valves_opened]
    end
  end

  graph_node = graph[node_index]
  openable_valves.each_with_index { |next_valve, next_valve_index|
    distance = graph_node[next_valve]
    if distance <= time_left
      new_time_left = time_left - distance
      score_key = [next_valve_index, valves_opened, new_time_left]
      if best_scores[score_key] < released_pressure
        best_scores[score_key] = released_pressure
        state_queue << [next_valve_index, released_pressure, new_time_left, valves_opened]
      end
    end
  }
end

permutation_count = 1 << openable_valves.size
permutations = Array.new(permutation_count, 0)
best_scores.each { |(_, valves_opened, _), released_pressure|
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