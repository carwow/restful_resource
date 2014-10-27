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

def expect_put(url, response, data: {})
  expect(@mock_http).to receive(:put).with(url, data).and_return(response)
end

def expect_put_with_unprocessable_entity(url, response, data: {})
  rest_client_response = OpenStruct.new({body: response.body, headers: response.headers, code: response.status})
  exception = RestfulResource::HttpClient::UnprocessableEntity.new(rest_client_response)
  expect(@mock_http).to receive(:put).with(url, data).and_raise(exception)
end
