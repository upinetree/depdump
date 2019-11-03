class Depdump
  class Registry
    class Tree
      class Relation
        attr_reader :node, :reference

        def initialize(node:, reference:, search_entry_node: nil)
          @node = node
          @reference = reference
          @search_entry_node = search_entry_node || node
        end

        def resolve(tree)
          resolved_node = tree.resolve(reference, @search_entry_node)
          resolved_node&.namespaces
        end
      end
    end
  end
end
