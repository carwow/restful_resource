require_relative '../spec_helper'

describe RestfulResource::HttpClient do
  describe 'Authentication' do
    before :each do
      auth = RestfulResource::Authorization.http_authorization('user', 'passwd')
      @http_client = RestfulResource::HttpClient.new(authorization: auth)
    end

    it 'should get authenticated get' do
      response = @http_client.get('http://httpbin.org/basic-auth/user/passwd')
      expect(response.status).to eq 200
    end
  end
end
