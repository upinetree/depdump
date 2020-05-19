require_relative "depdump/configurable"
require_relative "depdump/dependency_graph"
require_relative "depdump/parser"
require_relative "depdump/registry"
require_relative "depdump/tracer"
require_relative "depdump/version"

require "set"
require "parser/current"

module Depdump
  include Configurable

  class Cli
    def self.run(files)
      graph = Depdump::Parser.new.then { |p| p.parse(files) }
      Depdump.config.output.write(graph.format)
    end
  end
end
