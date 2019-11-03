class Depdump
  class Registry
    class Tree
      def root
        @root ||= Node.new(
          namespaces: [],
          parent: nil,
        )
      end

      def find_or_create_node(namespaces, parent)
        # TODO: could be cached rather than search everytime
        registered = root.detect { |node| parent.namespaces + namespaces == node.namespaces }
        return registered if registered

        Node.new(namespaces: namespaces, parent: parent).tap { |n|
          parent.children << n
        }
      end

      def each_node
        return unless block_given?
        root.each { |node| yield node }
      end
    end
  end
end
