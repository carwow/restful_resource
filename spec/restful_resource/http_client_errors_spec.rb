require_relative '../spec_helper'

describe RestfulResource::HttpClient::ServiceUnavailable do
  let(:request) { instance_double(RestfulResource::Request, url: 'http://httpbin.org/status/503') }
  let(:response) { Hash.new }
  subject { described_class.new request, response  }

  describe 'message' do
    it 'includes the request url' do
      expect(subject.message).to eq 'HTTP 503: Service unavailable http://httpbin.org/status/503'
    end
  end
end