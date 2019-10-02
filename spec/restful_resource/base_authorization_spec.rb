require_relative '../spec_helper'

describe RestfulResource::Base, 'authorization' do
  before do
    class FirstClient < RestfulResource::Base; end
    class SecondClient < RestfulResource::Base; end
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
                           password: 'test_pass'
                          )
  end

  it 'uses two different http instances' do
    expect(FirstTest.send(:http)).not_to equal(SecondTest.send(:http))
  end

  it 'has same http auth on superclass' do
    expect(SecondTest.send(:http)).to equal(SecondClient.send(:http))
  end

  it 'raises exception if base_url is not set' do
    expect { NotConfiguredClient.send(:base_url) }.to raise_error 'Base url missing'
  end
end
