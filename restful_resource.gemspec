lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restful_resource/version'

Gem::Specification.new do |spec|
  spec.name          = 'restful_resource'
  spec.version       = RestfulResource::VERSION
  spec.authors       = ['David Santoro', 'Federico Rebora']
  spec.email         = ['developers@carwow.co.uk']
  spec.description   = 'A simple activerecord inspired rest resource base class implemented using rest-client'
  spec.summary       = 'A simple activerecord inspired rest resource base class implemented using rest-client'
  spec.homepage      = 'http://www.github.com/carwow/restful_resource'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'carwow_rubocop'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rspec-its'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday', '>= 0.15', '< 1.1'
  spec.add_dependency 'faraday-cdn-metrics'
  spec.add_dependency 'faraday-encoding'
  spec.add_dependency 'faraday-http-cache'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'link_header'
  spec.add_dependency 'rack'
  spec.add_dependency 'typhoeus'
end
