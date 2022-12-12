monkey_items = [
  [98, 70, 75, 80, 84, 89, 55, 98],
  [59],
  [77, 95, 54, 65, 89],
  [71, 64, 75],
  [74, 55, 87, 98],
  [90, 98, 85, 52, 91, 60],
  [99, 51],
  [98, 94, 59, 76, 51, 65, 75],
]

monkey_operations = [
  -> (old) { old * 2 },
  -> (old) { old * old },
  -> (old) { old + 6 },
  -> (old) { old + 2 },
  -> (old) { old * 11 },
  -> (old) { old + 7 },
  -> (old) { old + 1 },
  -> (old) { old + 5 },
]

monkey_quotients = [
  11,
  19,
  7,
  17,
  3,
  5,
  13,
  2,
]

monkey_targets = [
  [1, 4],
  [7, 3],
  [0, 5],
  [6, 2],
  [1, 7],
  [0, 4],
  [5, 2],
  [3, 6],
]

monkey_inspections = Array.new(8, 0)

20.times {
  monkey_items.each_with_index { |items, index|
    monkey_operation = monkey_operations[index]
    true_target, false_target = monkey_targets[index]
    monkey_quotient = monkey_quotients[index]
    items.each { |worry|
      worry = monkey_operation.call(worry) / 3
      if worry % monkey_quotient == 0
        monkey_items[true_target] << worry
      else
        monkey_items[false_target] << worry
      end
    }
    monkey_inspections[index] += items.size
    monkey_items[index] = []
  }
}

pp "Inspections? #{monkey_inspections.sort}"