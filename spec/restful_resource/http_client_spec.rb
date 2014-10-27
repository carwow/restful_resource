require_relative '../spec_helper'

describe RestfulResource::HttpClient do
  describe 'Basic HTTP' do
    before :each do
      @http_client = RestfulResource::HttpClient.new
    end

    it 'should execute get' do
      response = @http_client.get('http://httpbin.org/get')
      expect(response.status).to eq 200
    end

    it 'should execute put' do
      response = @http_client.put('http://httpbin.org/put', data: { name: 'Alfred' })
      expect(response.status).to eq 200
    end

    it 'should raise error 422' do
      expect { @http_client.put('http://httpbin.org/status/422', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end
  end

  describe 'Authentication' do
    before :each do
      auth = RestfulResource::Authorization.http_authorization('user', 'passwd')
      @http_client = RestfulResource::HttpClient.new(authorization: auth)
    end

    it 'should execute authenticated get' do
      response = @http_client.get('http://httpbin.org/basic-auth/user/passwd')
      expect(response.status).to eq 200
    end
  end
end
