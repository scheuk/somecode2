# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'versioner/version'

Gem::Specification.new do |spec|
  spec.name          = "versioner"
  spec.version       = Versioner::VERSION
  spec.authors       = ["The DaRT"]
  spec.email         = ["dart@bestbuy.com"]
  spec.description   = %q{Bumps version in a VERSION file}
  spec.summary       = %q{Bumps version in a VERSION file}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 0.19.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yarjuf"
  spec.add_development_dependency "rake"
end
