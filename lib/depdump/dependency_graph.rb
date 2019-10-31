require "json"

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
          # TODO: log references failed to resolve
        end
      end
    end

    def format
      JSON.dump({
        nodes: nodes.values,
        edges: edges.to_a,
      })
    end
  end
end
