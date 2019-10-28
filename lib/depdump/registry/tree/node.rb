class Depdump
  class Registry
    class Tree
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
    end
  end
end
