require 'concurrent'

promises = Hash.new { |h, k| h[k] = Concurrent::Promises.resolvable_future }
anti_promises = Hash.new { |h, k| h[k] = Concurrent::Promises.resolvable_future }
File.readlines('input').each { |line|
  tokens = line.strip.split(" ")
  monkey_name = tokens[0][...-1].to_sym
  monkey_promise = promises[monkey_name]
  monkey_anti_promise = anti_promises[monkey_name]
  if tokens.size == 2
    value = tokens[1].to_i
    next if monkey_name == :humn
    monkey_promise.fulfill(value)
  else # Maths
    monkey_name2 = tokens[1].to_sym
    monkey_name3 = tokens[3].to_sym
    monkey_promise2 = promises[monkey_name2]
    monkey_promise3 = promises[monkey_name3]
    anti_promise2 = anti_promises[monkey_name2]
    anti_promise3 = anti_promises[monkey_name3]
    operation = tokens[2].to_sym

    if monkey_name == :root
      monkey_promise3.then { |rhs_val|
        anti_promise2.fulfill(rhs_val)
      }
    else
      (monkey_promise2 & monkey_promise3).then { |monkey2, monkey3|
        monkey_promise.fulfill([monkey2, monkey3].reduce(operation))
      }
      monkey_anti_promise.then { |eq_val|
        case operation
        when :+
          monkey_promise3.then { |rhs_val| anti_promise2.fulfill(eq_val - rhs_val) }
          monkey_promise2.then { |lhs_val| anti_promise3.fulfill(eq_val - lhs_val) }
        when :-
          monkey_promise3.then { |rhs_val| anti_promise2.fulfill(eq_val + rhs_val) }
          monkey_promise2.then { |lhs_val| anti_promise3.fulfill(lhs_val - eq_val) }
        when :*
          monkey_promise3.then { |rhs_val| anti_promise2.fulfill(eq_val / rhs_val) }
          monkey_promise2.then { |lhs_val| anti_promise3.fulfill(eq_val / lhs_val) }
        when :/ # I'm pretty disappointed, too
          monkey_promise3.then { |rhs_val| anti_promise2.fulfill(eq_val * rhs_val) }
          monkey_promise2.then { |lhs_val| anti_promise3.fulfill(lhs_val / eq_val) }
        end
      }
    end
  end
}

root_monkey = anti_promises[:humn]
pp "Root value: #{root_monkey.value}"