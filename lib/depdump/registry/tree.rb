module Depdump
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
        registered = root.detect { |node| namespaces == node.namespaces }
        return registered if registered

        Node.new(namespaces: namespaces, parent: parent).tap { |n|
          parent.children << n
        }
      end

      def each_node
        return unless block_given?
        root.each { |node| yield node }
      end

      def resolve(partial_namespaces, entry_node)
        current_node = entry_node
        resolved_node = nil

        while current_node && resolved_node.nil?
          resolved_node = current_node.dig(partial_namespaces)
          current_node = current_node&.parent
        end

        resolved_node
      end
    end
  end
end
