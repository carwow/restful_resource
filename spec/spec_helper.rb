require 'rspec'
require_relative '../lib/restful_resource'
require_relative 'fixtures'

RSpec.configure do |config|
  config.color = true
  config.formatter = :progress 
end


def expect_get(url, response)
  expect(@mock_http).to receive(:get).with(url).and_return(response)
end
