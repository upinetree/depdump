class Depdump
  class Registry
    class Tree
      def root
        @root ||= Node.new(
          namespaces: [:Object],
          parent: nil,
        )
      end

      def create_node(namespaces, parent)
        Node.new(namespaces: namespaces, parent: parent).tap { |n|
          parent.children << n
        }
      end

      def each_node
        return unless block_given?
        root.each { |node| yield node }
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
end
