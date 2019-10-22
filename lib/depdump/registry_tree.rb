class Depdump
  class RegistryTree
    class Node
      attr_accessor :namespaces
      attr_reader :children, :parent, :relations

      def initialize(namespaces: [], parent:)
        @namespaces = namespaces
        @relations = []
        @children = []
        @parent = parent
      end

      def create_relation(reference)
        Relation.new(node: self, reference: reference).tap { |r|
          @relations << r
        }
      end

      def search_down(partial_namespaces, except: nil)
        nest_size = partial_namespaces.size
        return self if partial_namespaces == namespaces.last(nest_size)

        searchable_children = except ? children.reject { |node| node.namespaces == except.namespaces } : children
        searchable_children.detect { |n| n.search_down(partial_namespaces) }
      end
    end

    class Relation
      attr_reader :node, :reference, :resolved_reference

      def initialize(node:, reference:, resolved_reference: nil)
        @node = node
        @reference = reference
      end

      def resolve(tree)
        resolved_node = tree.resolve(reference, node)
        @resolved_reference = resolved_node.namespaces
      end
    end

    def initialize
      @nodes = []
    end

    def root
      @root ||= Node.new(
        namespaces: [:Object], # Const object ?
        parent: nil,
      )
    end

    def create_node(parent:)
      Node.new(parent: parent).tap { |n|
        @nodes << n
        parent.children << n
      }
    end

    def resolve(partial_namespaces, entry_node, except_node: nil)
      found = entry_node.search_down(partial_namespaces, except: except_node)

      unless found
        parent = entry_node.parent
        return nil unless parent
        found = resolve(partial_namespaces, parent, except_node: entry_node)
      end

      found
    end
  end
end
