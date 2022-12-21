require 'concurrent'

promises = Hash.new { |h, k| h[k] = Concurrent::Promises.resolvable_future }
File.readlines('input').each { |line|
  tokens = line.strip.split(" ")
  monkey_promise = promises[tokens[0][...-1].to_sym]
  if tokens.size == 2
    monkey_promise.fulfill(tokens[1].to_i)
  else # Maths
    monkey_promise2 = promises[tokens[1].to_sym]
    monkey_promise3 = promises[tokens[3].to_sym]
    operation = tokens[2].to_sym
    (monkey_promise2 & monkey_promise3).then { |monkey2, monkey3|
      monkey_promise.fulfill([monkey2, monkey3].reduce(operation))
    }
  end
}

root_monkey = promises[:root]
pp "Root value: #{root_monkey.value}"
