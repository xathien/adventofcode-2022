require "set"

blueprints = eval(File.read('input'))

start_time = 32
start_conditions = {
  ore_robots: 1,
  clay_robots: 0,
  obsidian_robots: 0,
  ore: 1,
  clay: 0,
  obsidian: 0,
  geodes: 0,
  time_left: start_time - 1,
  decisions: [:nothing]
}

quality_levels = 0

blueprints.first(3).each_with_index { |blueprint, index|
  blueprint_id = index + 1
  pp "Starting blueprint #{blueprint_id}"

  ore_cost = blueprint[:ore]
  clay_cost = blueprint[:clay]
  obsidian_ore_cost, obsidian_clay_cost = blueprint[:obsidian]
  geode_ore_cost, geode_obsidian_cost = blueprint[:geode]
  max_ore_bots = [clay_cost, obsidian_ore_cost, geode_ore_cost].max

  best_time_states = {}

  queue = [start_conditions.dup]
  max_geodes = 0
  until queue.empty?
    state = queue.pop
    time_left = state[:time_left]
    geodes = state[:geodes]
    if time_left == 0
      if geodes > max_geodes
        pp "New max geodes: #{state}"
        max_geodes = geodes
      end
      next
    end

    max_possible_geodes = geodes + (time_left * time_left + time_left) / 2
    if max_possible_geodes < max_geodes
      # If we can't beat the max_geodes by making a geode bot every turn, don't bother
      next
    end

    # Increment all our daggum values
    ore_robots = state[:ore_robots]
    clay_robots = state[:clay_robots]
    obsidian_robots = state[:obsidian_robots]
    ore = state[:ore]
    state[:ore] += ore_robots
    clay = state[:clay]
    state[:clay] += clay_robots
    obsidian = state[:obsidian]
    state[:obsidian] += obsidian_robots

    # See if this state is worth visiting or if we've been here (or better) before
    time_state_key = [ore_robots, clay_robots, obsidian_robots, ore, clay, obsidian, geodes, time_left]
    next if best_time_states.key?(time_state_key)
    best_time_states[time_state_key] = true

    # Figure out possible actions
    if ore >= ore_cost && ore_robots < max_ore_bots
      new_state = state.dup
      new_state[:ore] -= ore_cost
      new_state[:ore_robots] += 1
      new_state[:time_left] -= 1
      new_state[:decisions] = new_state[:decisions] + [:ore]
      queue << new_state
    end

    if ore >= clay_cost && clay_robots < obsidian_clay_cost
      new_state = state.dup
      new_state[:ore] -= clay_cost
      new_state[:clay_robots] += 1
      new_state[:time_left] -= 1
      new_state[:decisions] = new_state[:decisions] + [:clay]
      queue << new_state
    end

    if ore >= obsidian_ore_cost && clay >= obsidian_clay_cost && obsidian_robots < geode_obsidian_cost
      new_state = state.dup
      new_state[:ore] -= obsidian_ore_cost
      new_state[:clay] -= obsidian_clay_cost
      new_state[:obsidian_robots] += 1
      new_state[:time_left] -= 1
      new_state[:decisions] = new_state[:decisions] + [:obsidian]
      queue << new_state
    end

    if ore >= geode_ore_cost && obsidian >= geode_obsidian_cost
      new_state = state.dup
      new_state[:ore] -= geode_ore_cost
      new_state[:obsidian] -= geode_obsidian_cost
      time_left = new_state[:time_left] -= 1
      new_state[:geodes] += time_left
      new_state[:decisions] = new_state[:decisions] + ["geodes (#{time_left})"]
      queue << new_state
    else
      # Do nothing is always an action if we can't make a geode bot
      new_state = state.dup
      new_state[:time_left] -= 1
      new_state[:decisions] = new_state[:decisions] + [:nothing]
      queue << new_state
    end

  end

  pp "How did we do? #{max_geodes} for a quality level of #{max_geodes * (index + 1)}"
  quality_levels += max_geodes * (index + 1)
}
