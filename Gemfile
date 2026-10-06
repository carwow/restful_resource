source 'https://rubygems.org'

gemspec

# Lets CI test against each supported Faraday major version, e.g. FARADAY_VERSION=1.10
gem 'faraday', "~> #{ENV['FARADAY_VERSION']}" if ENV['FARADAY_VERSION']

# json 3 dropped the quirks_mode option that ActiveSupport 7.1 (the newest that runs on Ruby < 3.1) still passes
gem 'json', '< 3' if RUBY_VERSION < '3.1'
