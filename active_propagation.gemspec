# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_propagation/version'

Gem::Specification.new do |spec|
  spec.name          = "active_propagation"
  spec.version       = ActivePropagation::VERSION
  spec.authors       = ["Yoshiki Schmitz"]
  spec.email         = ["yoshiki@masteryconnect.com"]

  spec.summary       = %q{propagates changes across models}
  spec.description   = %q{ActivePropagation provides classes and ActiveRecord extensions for propagating changes amongst models, optionally using Sidekiq to parallelize the process.}
  spec.homepage      = "https://bitbucket.org/doweber/active_propagation/overview"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "pry"

  spec.add_dependency "activerecord", "~> 4.0"
  spec.add_dependency "activesupport", "~> 4.0"
end
