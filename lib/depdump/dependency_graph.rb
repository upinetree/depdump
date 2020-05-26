require_relative 'dependency_graph/formatter'

module Depdump
  class DependencyGraph
    attr_reader :nodes, :edges

    def initialize(tree)
      @nodes = Set.new
      @edges = Set.new
      build(tree)
    end

    def build(tree)
      tree.each_node do |node|
        next if node == tree.root

        @nodes << node
        node.relations.each do |r|
          referenced_namespaces = r.resolve(tree)
          if referenced_namespaces
            @edges << { from: node.namespaces, to: referenced_namespaces }
          else
            if allow_unresolvable_constant?
              @edges << { from: node.namespaces, to: r.reference }
            else
              # TODO: Show file path and line no.
              warn "[skip] cannot resolve: #{node.namespaces} => #{r.reference}"
            end
          end
        end
      end
    end

    def format
      Depdump.config.formatter.call(nodes, edges)
    end

    private

    def allow_unresolvable_constant?
      Depdump.config.strict == false
    end
  end
end
