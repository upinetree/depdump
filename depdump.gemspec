lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "depdump/version"

Gem::Specification.new do |spec|
  spec.name = "depdump"
  spec.version = Depdump::VERSION
  spec.authors = ["upinetree"]
  spec.email = ["upinetree@gmail.com"]

  spec.summary = %q{A dump tool of ruby class/module dependencies.}
  spec.description = %q{A dump tool of ruby class/module dependencies.}
  spec.homepage = "https://github.com/upinetree/depdump"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/upinetree/depdump"
  spec.metadata["changelog_uri"] = "https://github.com/upinetree/depdump/commits/master"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "parser", "~> 2.6"

  spec.add_development_dependency "bundler", '>= 1.17.0', ">= 2.0.0"
  spec.add_development_dependency "rake"
end
