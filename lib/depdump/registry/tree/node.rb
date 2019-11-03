class Depdump
  class Registry
    class Tree
      class Node
        include Enumerable

        attr_accessor :namespaces
        attr_reader :children, :parent, :relations

        def initialize(namespaces: [], parent:)
          @namespaces = namespaces
          @relations = []
          @children = []
          @parent = parent
        end

        def create_relation(reference, search_entry_node: nil)
          Relation.new(node: self, reference: reference, search_entry_node: search_entry_node).tap { |r|
            @relations << r
          }
        end

        def root?
          parent.nil?
        end

        def key
          namespaces.map(&:downcase).join("/")
        end

        def each(&block)
          return unless block_given?

          children.each do |child|
            yield child
            child.each(&block)
          end
        end

        def resolve(partial_namespaces, except_node: nil)
          found = search_kinship(partial_namespaces, except: except_node)

          unless found
            return nil unless parent
            found = parent.resolve(partial_namespaces, except_node: self)
          end

          found
        end

        def search_kinship(partial_namespaces, except: nil, degree: 1)
          return self if partial_namespaces == namespaces.last(partial_namespaces.size)
          return self if parent&.root? && partial_namespaces == namespaces # top level refenrece
          return unless degree > 0

          searchable_children = except ? children.reject { |node| node.namespaces == except.namespaces } : children
          searchable_children.detect { |n| n.search_kinship(partial_namespaces, degree: degree - 1) }
        end
      end
    end
  end
end
