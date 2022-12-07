class Dir
  attr_accessor :children, :files

  def initialize
    @children = {}
    @files = []
    @size = 0
  end

  def add_child(name)
    children[name] = Dir.new
  end

  def add_file(name, size)
    @files << name
    @size += size
  end

  def cd(name)
    children[name]
  end

  def size
    children_size, children_reportable_size = children.values.reduce([0, 0]) { |(total_size, reportable_size), dir|
      child_size, child_reportable_size = dir.size
      [total_size + child_size, reportable_size + child_reportable_size]
    }
    total = @size + children_size
    if total > 100_000
      [total, children_reportable_size]
    else
      [total, total + children_reportable_size]
    end
  end
end

ROOT = Dir.new
path = [ROOT]

File.readlines('input').each { |line|
  tokens = line.strip.split(" ")
  case tokens[0]
  when "$"
    next unless tokens[1] == "cd"
    case tokens[2]
    when ".."
      path.pop
    else
      path << path.last.cd(tokens[2])
    end
  when "dir"
    path.last.add_child(tokens[1])
  else
    path.last.add_file(tokens[1], tokens[0].to_i)
  end
}

pp "Total? #{ROOT.size[1]}"