require 'parser/current'

class Depdump
  def parse_text(source)
    ast = Parser::CurrentRuby.parse(source)
    Tracer.run(ast)
  end

  private

  class Tracer
    attr_reader :classes, :relations

    def self.run(ast)
      tracer = new.tap { |t| t.trace_node(ast) }

      {
        classes: tracer.classes.to_a,
        relations: tracer.relations.to_a
      }
    end

    def initialize
      @classes = Set.new
      @relations = Set.new
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
        defined_namespaces = []
        definition_node = node.children.first

        if definition_node.type == :const
          defined_namespaces = expand_const_namespaces(definition_node, namespaces)
          @classes << defined_namespaces
        end

        node.children[1..-1].each { |n| trace_node(n, defined_namespaces) }
      when :const
        referenced_namespaces = expand_const_namespaces(node, [])
        @relations << { from: namespaces, to: referenced_namespaces }
      else
        node.children.map { |n| trace_node(n, namespaces) }
      end
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
