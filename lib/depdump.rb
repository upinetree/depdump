require "depdump/version"
require "depdump/tracer"

require "parser/current"

class Depdump
  def parse_text(source)
    ast = Parser::CurrentRuby.parse(source)
    Tracer.run(ast)
  end
end
