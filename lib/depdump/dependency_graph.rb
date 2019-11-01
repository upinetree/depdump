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
        next if node == tree.root

        @nodes[node.key] ||= node.namespaces
        node.relations.each do |r|
          referenced_namespaces = r.resolve(tree)
          if referenced_namespaces
            @edges << { from: node.namespaces, to: referenced_namespaces }
          else
            # TODO: Show file path and line no.
            warn "[skip] cannot resolve: #{node.namespaces} => #{r.reference}"
          end
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
