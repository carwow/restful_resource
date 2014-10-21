require 'rspec'
require_relative '../lib/restful_resource'
require_relative 'fixtures'

RSpec.configure do |config|
  config.color = true
  config.formatter = :progress 
end
