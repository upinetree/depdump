require_relative "depdump/registry"
require_relative "depdump/tracer"
require_relative "depdump/dependency_graph"
require_relative "depdump/configurable"
require_relative "depdump/version"

require "parser/current"

class Depdump
  include Configurable

  def run(files)
    graph = parse_files(files)
    config.output.write(graph.format)
  end

  def parse_files(files)
    tracer = Tracer.new

    expand_directory(files).each do |file|
      source = File.read(file)
      ast = Parser::CurrentRuby.parse(source)
      tracer.trace_node(ast)
    end

    DependencyGraph.new(tracer.registry_tree)
  end

  def parse_string(source)
    ast = Parser::CurrentRuby.parse(source)

    tracer = Tracer.new.tap { |t| t.trace_node(ast) }
    graph = DependencyGraph.new(tracer.registry_tree)

    {
      nodes: graph.nodes.values,
      edges: graph.edges.to_a,
    }
  end

  private

  def expand_directory(paths)
    paths.flat_map do |path|
      if File.directory?(path)
        Dir.glob(File.join(path, "**", "*.rb"))
      else
        path
      end
    end
  end
end
