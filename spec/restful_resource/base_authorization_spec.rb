require_relative '../spec_helper'

describe RestfulResource::Base, 'authorization' do
  before :each do
    class FirstClient < RestfulResource::Base
    end

    class SecondClient < RestfulResource::Base
    end

    class NotConfiguredClient < RestfulResource::Base; end

    class FirstTest < FirstClient
      resource_path 'test'
    end

    class SecondTest < SecondClient
      resource_path 'test'
    end

    FirstClient.configure(base_url: 'http://api.carwow.co.uk/api/first')
    SecondClient.configure(base_url: 'http://api.carwow.co.uk/api/second',
                           username: 'test_user',
                           password: 'test_pass')
  end

  it "should use two different http instances" do
    expect(FirstTest.send(:http)).not_to equal(SecondTest.send(:http))
  end

  it 'should have http auth on SecondClient when initialised first' do
    SecondTest.send(:http)
    FirstTest.send(:http)

    authorization = SecondTest.send(:http).instance_variable_get :@authorization
    expect(authorization).to be_truthy
  end

  it 'should have http auth on SecondTest when initialised second' do
    FirstTest.send(:http)
    SecondTest.send(:http)

    authorization = SecondTest.send(:http).instance_variable_get :@authorization
    expect(authorization).to be_truthy
  end

  it 'should have same http auth on superclass' do
    expect(SecondTest.send(:http)).to equal(SecondClient.send(:http))
  end

  it 'should raise exception if base_url is not set' do
    expect { NotConfiguredClient.send(:base_url) }.to raise_error 'Base url missing'
  end

end

