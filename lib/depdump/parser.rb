module Depdump
  class Parser
    def initialize
      @tracer = Tracer.new
    end

    def parse(files)
      expand_directory(files).each do |file|
        source = File.read(file)
        ast = ::Parser::CurrentRuby.parse(source)
        @tracer.trace_node(ast)
      end
    end

    def dependency_graph
      DependencyGraph.new(@tracer.registry_tree)
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
end
