require 'parser/current'

class Depdump
  def parse_text(source)
    ast = Parser::CurrentRuby.parse(source)
    Tracer.run(ast)
  end

  private

  class Tracer
    def self.run(ast)
      classes_set = new.trace_node(ast)
      { classes: classes_set.to_a }
    end

    def initialize
      @classes = Set.new
    end

    def trace_node(node, namespaces = [])
      with_debug do
        p '-' * 30
        pp namespaces
        pp node
      end

      return unless node.respond_to?(:type)

      case node.type
      when :class, :module
        definition_node = node.children.first
        if definition_node.type == :const
          detected_namespaces = trace_definitions(definition_node, namespaces)
          @classes << detected_namespaces
        end
        node.children[1..-1].each { |n| trace_node(n, detected_namespaces) }
      else
        node.children.map { |n| trace_node(n, namespaces) }
      end

      @classes.to_a
    end

    def trace_definitions(node, namespaces)
      valid_definition = node.respond_to?(:type) && node.type == :const
      return namespaces unless valid_definition

      maybe_qualifing_node = node.children.first
      qualified_namespaces = trace_definitions(maybe_qualifing_node, namespaces)
      qualified_namespaces + [node.children.last]
    end

    def with_debug
      return unless ENV['DEBUG']
      yield
    end
  end
end
