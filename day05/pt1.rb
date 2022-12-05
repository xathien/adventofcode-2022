stacks = [
  [],
  %w(G T R W),
  %w(G C H P M S V W),
  %w(C L T S G M),
  %w(J H D M W R F),
  %w(P Q L H S W F J),
  %w(P J D N F M S),
  %w(Z B D F G C S J),
  %w(R T B),
  %w(H N W L C),
]

File.readlines('input')
    .each do |line|
      _, number, _, source, _, dest = line.strip.split(" ").map(&:to_i)
      stacks[dest].push(*stacks[source].pop(number).reverse)
    end

top_crates = stacks.map(&:pop).join
pp "Top? #{top_crates}"