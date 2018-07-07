# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restful_resource/version'

Gem::Specification.new do |spec|
  spec.name          = "restful_resource"
  spec.version       = RestfulResource::VERSION
  spec.authors       = ["David Santoro", "Federico Rebora"]
  spec.email         = ["developers@carwow.co.uk"]
  spec.description   = %q{A simple activerecord inspired rest resource base class implemented using rest-client}
  spec.summary       = %q{A simple activerecord inspired rest resource base class implemented using rest-client}
  spec.homepage      = "http://www.github.com/carwow/restful_resource"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "pry"

  spec.add_dependency "faraday"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "faraday-http-cache"
  spec.add_dependency "faraday-encoding"
  spec.add_dependency "link_header"
  spec.add_dependency "activesupport"
  spec.add_dependency "rack"
  spec.add_dependency "typhoeus"
  spec.add_dependency "faraday-cdn-metrics"
end
