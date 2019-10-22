require "depdump/registry_tree"
require "depdump/tracer"
require "depdump/version"

require "parser/current"

class Depdump
  def parse_text(source)
    ast = Parser::CurrentRuby.parse(source)
    Tracer.run(ast)
  end
end
