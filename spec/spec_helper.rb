require 'rspec'
require 'rspec/its'
require_relative '../lib/restful_resource'
require_relative 'fixtures'

RSpec.configure do |config|
  config.color = true
  config.formatter = :progress
end

def expect_get(url, response, headers: {}, open_timeout: nil, timeout: nil)
  expect(@mock_http).to receive(:get)
    .with(url, headers: headers, open_timeout: open_timeout, timeout: timeout)
    .and_return(response)
end

def expect_delete(url, response, headers: {}, open_timeout: nil, timeout: nil)
  expect(@mock_http).to receive(:delete)
    .with(url, headers: headers, open_timeout: open_timeout, timeout: timeout)
    .and_return(response)
end

def expect_patch(url, response, data: {}, headers: {}, open_timeout: nil, timeout: nil)
  expect(@mock_http).to receive(:patch)
    .with(url, data: data, headers: headers, open_timeout: open_timeout, timeout: timeout)
    .and_return(response)
end

def expect_put(url, response, data: {}, headers: {}, open_timeout: nil, timeout: nil)
  expect(@mock_http).to receive(:put)
    .with(url, data: data, headers: headers, open_timeout: open_timeout, timeout: timeout)
    .and_return(response)
end

def expect_post(url, response, data: {}, headers: {}, open_timeout: nil, timeout: nil)
  expect(@mock_http).to receive(:post)
    .with(url, data: data, headers: headers, open_timeout: open_timeout, timeout: timeout)
    .and_return(response)
end

def expect_get_with_unprocessable_entity(url, response)
  request = RestfulResource::Request.new(:get, url)
  rest_client_response = OpenStruct.new(body: response.body, headers: response.headers, code: response.status)
  exception = RestfulResource::HttpClient::UnprocessableEntity.new(request, rest_client_response)
  expect(@mock_http).to receive(:get).with(url, headers: {}, open_timeout: nil, timeout: nil).and_raise(exception)
end

def expect_put_with_unprocessable_entity(url, response, data: {})
  request = RestfulResource::Request.new(:put, url, body: data)
  rest_client_response = OpenStruct.new(body: response.body, headers: response.headers, code: response.status)
  exception = RestfulResource::HttpClient::UnprocessableEntity.new(request, rest_client_response)
  expect(@mock_http).to receive(:put).with(url, data: data, headers: {}, open_timeout: nil, timeout: nil).and_raise(exception)
end

def expect_post_with_unprocessable_entity(url, response, data: {})
  request = RestfulResource::Request.new(:put, url, body: data)
  rest_client_response = OpenStruct.new(body: response.body, headers: response.headers, code: response.status)
  exception = RestfulResource::HttpClient::UnprocessableEntity.new(request, rest_client_response)
  expect(@mock_http).to receive(:post).with(url, data: data, headers: {}, open_timeout: nil, timeout: nil).and_raise(exception)
end
