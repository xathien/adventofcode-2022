require 'set'

move_order = [:n, :s, :w, :e, :n, :s, :w]
locations = Set.new
intents = {}
intent_counts = Hash.new { |h, k| h[k] = 0 }

File.readlines("input").each_with_index { |line, y|
  line.strip.chars.each_with_index { |char, x|
    next unless char == "#"
    locations << [x, y]
  }
}

move_order_index = -1
turn_count = 0
anyone_moved = true
while anyone_moved
  turn_count += 1
  intent_counts.clear
  intents.clear

  move_order_index = (move_order_index + 1) % 4
  round_move_order = move_order.drop(move_order_index).first(4)
  # Set intents
  locations.each { |(x, y)|
    target_coords = nil
    stay_put = (y-1..y+1).all? { |target_y|
      (x-1..x+1).none? { |target_x|
        !(target_x == x && target_y == y) && locations.include?([target_x, target_y])
      }
    }
    unless stay_put
      round_move_order.each { |dir|
        target_x = x
        target_y = y
        empty = false
        case dir
        when :n
          target_y = y - 1
          empty = (x-1..x+1).none? { |target_x| locations.include?([target_x, target_y]) }
        when :s
          target_y = y + 1
          empty = (x-1..x+1).none? { |target_x| locations.include?([target_x, target_y]) }
        when :w
          target_x = x - 1
          empty = (y-1..y+1).none? { |target_y| locations.include?([target_x, target_y]) }
        when :e
          target_x = x + 1
          empty = (y-1..y+1).none? { |target_y| locations.include?([target_x, target_y]) }
        end

        if empty
          target_coords = [target_x, target_y]
          intent_counts[[target_x, target_y]] += 1
          break
        end
      }
    end
    # pp "Elf at #{[x, y]} wants to move to #{target_coords}"
    intents[[x, y]] = target_coords
  }

  # Move
  locations.clear
  anyone_moved = false
  intents.each { |start_coords, target_coords|
    if !target_coords.nil? && intent_counts[target_coords] == 1
      # pp "Elf at #{start_coords} can move to #{target_coords}"
      locations << target_coords
      anyone_moved = true
    else # No target or contended space; don't move
      # pp "Elf at #{start_coords} gets to stay put"
      locations << start_coords
    end
  }
end

pp "Turn count: #{turn_count}"