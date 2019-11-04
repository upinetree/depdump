require_relative "depdump/registry"
require_relative "depdump/tracer"
require_relative "depdump/dependency_graph"
require_relative "depdump/configurable"
require_relative "depdump/parser"
require_relative "depdump/version"

require "parser/current"

class Depdump
  include Configurable

  class Cli
    def self.run(files)
      parser = Depdump::Parser.new.tap { |p| p.parse(files) }
      graph = parser.dependency_graph
      Depdump.config.output.write(graph.format)
    end
  end
end
