# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'malsh/version'

Gem::Specification.new do |spec|
  spec.name          = "malsh"
  spec.version       = Malsh::VERSION
  spec.authors       = ["kazuhiko yamahsita"]
  spec.email         = ["pyama@pepabo.com"]

  spec.summary       = %q{mackerel tools.}
  spec.description   = %q{mackerel tools.}
  spec.homepage      = "http://ten-snapon.com."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'mackerel-rb'
  spec.add_dependency 'slack-notifier'
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
