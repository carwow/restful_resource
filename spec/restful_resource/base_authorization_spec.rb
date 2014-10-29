require_relative '../spec_helper'

describe "http client" do
  before :each do
    class FirstClient < RestfulResource::Base
    end

    class SecondClient < RestfulResource::Base
    end

    class FirstTest < FirstClient
      resource_path 'test'
    end

    class SecondTest < SecondClient
      resource_path 'test'
    end

    FirstClient.http = nil
    FirstClient.base_url = 'http://api.carwow.co.uk/api/first'
    SecondClient.http = nil
    SecondClient.base_url = 'http://api.carwow.co.uk/api/second'
    SecondClient.http_authorization('test_user', 'test_pass')
  end

  it "should use two different http instances" do
    expect(FirstTest.http).not_to equal(SecondTest.http)
  end

  it 'should have http auth on SecondClient when initialised first' do
    SecondTest.http
    FirstTest.http

    authorization = SecondTest.http.instance_variable_get :@authorization
    expect(authorization).to be_truthy
  end

  it 'should have http auth on SecondTest when initialised second' do
    FirstTest.http
    SecondTest.http

    authorization = SecondTest.http.instance_variable_get :@authorization
    expect(authorization).to be_truthy
  end
end

