require "json"

module Depdump
  class DependencyGraph
    module Formatter
      class Json
        def call(nodes, edges)
          JSON.dump({
            nodes: nodes.map(&:namespaces),
            edges: edges.to_a,
          })
        end
      end

      class Table
        def call(_nodes, edges)
          rows = [
            "| From | To  |",
            "| ---  | --- |",
          ]
          rows = rows + edges.map do |edge|
            ["|", edge[:from].join("::"), "|", edge[:to].join("::"), "|"].join(" ")
          end
          rows.join("\n")
        end
      end
    end
  end
end
