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

def expect_delete(url, response)
  expect(@mock_http).to receive(:delete).with(url).and_return(response)
end

def expect_put(url, response, data: {})
  expect(@mock_http).to receive(:put).with(url, data: data).and_return(response)
end

def expect_post(url, response, data: {})
  expect(@mock_http).to receive(:post).with(url, data: data).and_return(response)
end

def expect_put_with_unprocessable_entity(url, response, data: {})
  rest_client_response = OpenStruct.new({body: response.body, headers: response.headers, code: response.status})
  exception = RestfulResource::HttpClient::UnprocessableEntity.new(rest_client_response)
  expect(@mock_http).to receive(:put).with(url, data: data).and_raise(exception)
end

def expect_post_with_unprocessable_entity(url, response, data: {})
  rest_client_response = OpenStruct.new({body: response.body, headers: response.headers, code: response.status})
  exception = RestfulResource::HttpClient::UnprocessableEntity.new(rest_client_response)
  expect(@mock_http).to receive(:post).with(url, data: data).and_raise(exception)
end
