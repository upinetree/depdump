require_relative "depdump/registry"
require_relative "depdump/tracer"
require_relative "depdump/dependency_graph"
require_relative "depdump/version"

require "parser/current"

class Depdump
  def run(file)
    source = File.read(file)
    parse_string(source)
  end

  def parse_string(source)
    ast = Parser::CurrentRuby.parse(source)

    tracer = Tracer.new.tap { |t| t.trace_node(ast) }
    graph = DependencyGraph.new(tracer.registry_tree)

    {
      nodes: graph.nodes.values,
      edges: graph.edges,
    }
  end
end
