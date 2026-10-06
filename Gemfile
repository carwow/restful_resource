source 'https://rubygems.org'

gemspec

# Lets CI test against each supported Faraday major version, e.g. FARADAY_VERSION=1.10
gem 'faraday', "~> #{ENV['FARADAY_VERSION']}" if ENV['FARADAY_VERSION']
