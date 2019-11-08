module Depdump
  class Tracer
    attr_reader :classes, :relations, :registry_tree

    def initialize
      @registry_tree = Registry::Tree.new
      @context = @registry_tree.root
    end

    def trace_node(node, namespaces = [])
      return unless node.respond_to?(:type)

      case node.type
      when :class, :module
        trace_class(node, namespaces)
      when :const
        trace_const(node, namespaces)
      else
        node.children.map { |n| trace_node(n, namespaces) }
      end
    end

    private

    def trace_class(node, namespaces)
      definition_node = node.children.first

      # definition_node.type should be :const (otherwise syntax error occurs)
      defined_namespaces = expand_const_namespaces(definition_node, namespaces)

      # Assume as top level definition is the rest of the array after last nil (cbase) appeared
      # e.g.) [nil, :A, nil, :B] => [:B]
      if cbase_index = defined_namespaces.rindex(nil)
        namespaces_size_from_top = defined_namespaces.size - (cbase_index + 1)
        defined_namespaces = defined_namespaces.last(namespaces_size_from_top)
      end

      stack_context(defined_namespaces) do
        node.children[1..-1].each { |n| trace_node(n, defined_namespaces) }
      end
    end

    def trace_const(node, namespaces)
      referenced_namespaces = expand_const_namespaces(node, [])

      if referenced_namespaces.first.nil?
        # Top level nil is inserted when :cbase appeared
        @context.create_relation(referenced_namespaces[1..-1], search_entry_node: @registry_tree.root)
      else
        @context.create_relation(referenced_namespaces)
      end
    end

    def stack_context(namespaces)
      prev_context = @context
      @context = @registry_tree.find_or_create_node(namespaces, prev_context)

      yield

      @context = prev_context
    end

    # returns [nil] if node.type is :cbase
    def expand_const_namespaces(node, namespaces)
      valid_definition = node.respond_to?(:type) && [:const, :cbase].include?(node.type)
      return namespaces unless valid_definition

      maybe_qualifing_node = node.children.first
      qualified_namespaces = expand_const_namespaces(maybe_qualifing_node, namespaces)
      qualified_namespaces + [node.children.last]
    end
  end
end
