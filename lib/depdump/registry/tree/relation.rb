class Depdump
  class Registry
    class Tree
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
    end
  end
end
