class Depdump
  class Tracer
    attr_reader :classes, :relations, :registry

    def self.run(ast)
      tracer = new.tap { |t| t.trace_node(ast) }

      {
        classes: tracer.classes.to_a,
        relations: tracer.relations.map { |r|
          { from: r.node.namespaces, to: r.reference }
        },
      }
    end

    def initialize
      @classes = Set.new
      @relations = Set.new
      @registry = RegistryTree.new
      @context = @registry.root
    end

    def trace_node(node, namespaces = [])
      return unless node.respond_to?(:type)

      case node.type
      when :class, :module
        defined_namespaces = []
        definition_node = node.children.first

        stack_context do
          if definition_node.type == :const
            defined_namespaces = expand_const_namespaces(definition_node, namespaces)
            @classes << defined_namespaces
            @context.namespaces = defined_namespaces
          end

          node.children[1..-1].each { |n| trace_node(n, defined_namespaces) }
        end
      when :const
        referenced_namespaces = expand_const_namespaces(node, [])
        @relations << @context.create_relation(referenced_namespaces)
      else
        node.children.map { |n| trace_node(n, namespaces) }
      end
    end

    def resolve_relations
      @relations.each { |r| r.resolve(@registry) }
    end

    private

    def stack_context
      prev_context = @context
      @context = @registry.create_node(parent: prev_context)

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
      return unless ENV['DEBUG']
      yield
    end
  end
end
