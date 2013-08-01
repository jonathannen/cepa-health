# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cepa-health/version'

Gem::Specification.new do |gem|
  gem.name          = "cepa-health"
  gem.version       = CepaHealth::VERSION
  gem.authors       = ["Jon Williams"]
  gem.email         = ["jon@jonathannen.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rack', '>= 1.2.0'
  gem.add_development_dependency 'rspec', '>= 2.0.0'
end
