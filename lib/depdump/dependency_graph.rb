class Depdump
  class DependencyGraph
    attr_reader :nodes, :edges

    def initialize(tree)
      @nodes = {}
      @edges = Set.new
      build(tree)
    end

    def build(tree)
      tree.each_node do |node|
        @nodes[node.key] ||= node.namespaces
        node.relations.each do |r|
          referenced_namespaces = r.resolve(tree)
          @edges << { from: node.namespaces, to: referenced_namespaces } if referenced_namespaces
        end
      end
    end
  end
end
