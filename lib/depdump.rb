require_relative "depdump/registry_tree"
require_relative "depdump/tracer"
require_relative "depdump/version"

require "parser/current"

class Depdump
  def parse_text(source)
    ast = Parser::CurrentRuby.parse(source)
    Tracer.run(ast)
  end
end