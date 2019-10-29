class Depdump
  class Registry
    class Tree
      class Relation
        attr_reader :node, :reference

        def initialize(node:, reference:)
          @node = node
          @reference = retrieve_top_level(reference)
        end

        def retrieve_top_level(reference)
          reference.map { |const| const || :Object }
        end

        def resolve(tree)
          resolved_node = tree.resolve(reference, node)
          resolved_node&.namespaces
        end
      end
    end
  end
end
