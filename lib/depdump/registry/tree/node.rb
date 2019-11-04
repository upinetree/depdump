module Depdump
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

        def dig(partial_namespaces)
          found = nil

          children.each do |node|
            exactly_match = node.namespaces.last(partial_namespaces.size) == partial_namespaces
            found = node and break if exactly_match

            route_match = node.namespaces.last == partial_namespaces.first
            if route_match
              found = node.dig(partial_namespaces[1..-1])
              break if found
            end
          end

          found
        end
      end
    end
  end
end
