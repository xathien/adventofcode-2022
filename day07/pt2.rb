class Dir
  attr_accessor :children, :files

  def initialize
    @children = {}
    @filesize = 0
  end

  def add_child(name)
    children[name] = Dir.new
  end

  def add_file(_name, size)
    @filesize += size
  end

  def cd(name)
    children[name]
  end

  def size
    @size ||= @filesize + children.values.sum(&:size)
  end

  def find_target(min)
    min = size if size < min && size >= TARGET
    children.values.reduce(min) { |sub_min, dir|
      dir.find_target(sub_min)
    }
  end

  def sizes(sizes)
    sizes << size
    children.values.each { |dir| dir.sizes(sizes) }
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

TARGET = ROOT.size - 40_000_000
pp "Size? #{ROOT.find_target(ROOT.size)}"