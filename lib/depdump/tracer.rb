class Depdump
  class Tracer
    attr_reader :classes, :relations, :registry_tree

    def self.run(ast)
      tracer = new.tap { |t| t.trace_node(ast) }
      graph = tracer.build_dependency_graph

      {
        nodes: graph.nodes.values,
        edges: graph.edges,
      }
    end

    def initialize
      @registry_tree = Registry::Tree.new
      @context = @registry_tree.root
    end

    def trace_node(node, namespaces = [])
      return unless node.respond_to?(:type)

      case node.type
      when :class, :module
        definition_node = node.children.first

        # definition_node.type should be :const (otherwise syntax error occurs)
        defined_namespaces = expand_const_namespaces(definition_node, namespaces)

        stack_context(defined_namespaces) do
          node.children[1..-1].each { |n| trace_node(n, defined_namespaces) }
        end
      when :const
        referenced_namespaces = expand_const_namespaces(node, [])
        @context.create_relation(referenced_namespaces)
      else
        node.children.map { |n| trace_node(n, namespaces) }
      end
    end

    def build_dependency_graph
      DependencyGraph.new(@registry_tree)
    end

    private

    def stack_context(namespaces)
      prev_context = @context
      @context = @registry_tree.create_node(namespaces, prev_context)

      yield

      @context = prev_context
    end

    def expand_const_namespaces(node, namespaces)
      valid_definition = node.respond_to?(:type) && node.type == :const
      return namespaces unless valid_definition

      maybe_qualifing_node = node.children.first
      qualified_namespaces = expand_const_namespaces(maybe_qualifing_node, namespaces)
      qualified_namespaces + [node.children.last]
    end

    def with_debug
      return unless ENV["DEBUG"]
      yield
    end
  end
end
