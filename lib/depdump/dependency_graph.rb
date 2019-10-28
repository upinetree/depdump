class DependencyGraph
  attr_reader :nodes, :edges

  def initialize(tree)
    @nodes = {}
    @edges = []
    build(tree)
  end

  def build(tree)
    tree.each_node do |node|
      @nodes[node.key] ||= node.namespaces
      node.relations.each do |r|
        @edges << { from: node.namespaces, to: r.resolve(tree) }
      end
    end
  end
end
