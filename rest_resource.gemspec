# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest_resource/version'

Gem::Specification.new do |spec|
  spec.name          = "rest_resource"
  spec.version       = RestResource::VERSION
  spec.authors       = ["David Santoro"]
  spec.email         = ["developers@carwow.co.uk"]
  spec.description   = %q{A simple activerecord inspired rest resource base class implemented using rest-client}
  spec.summary       = %q{A simple activerecord inspired rest resource base class implemented using rest-client}
  spec.homepage      = "http://www.github.com/carwow/rest_resource"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "rest-client"
  spec.add_dependency "link_header"
  spec.add_dependency "activesupport"
end
