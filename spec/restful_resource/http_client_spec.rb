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

    it 'should execute post' do
      response = @http_client.post('http://httpbin.org/post', data: { name: 'Alfred' })
      expect(response.body).to include "name\": \"Alfred"
      expect(response.status).to eq 200
    end

    it 'should execute delete' do
      response = @http_client.delete('http://httpbin.org/delete')
      expect(response.status).to eq 200
    end

    it 'put should raise error 422' do
      expect { @http_client.put('http://httpbin.org/status/422', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'post should raise error 422' do
      expect { @http_client.post('http://httpbin.org/status/422', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'put should raise error 503' do
      expect { @http_client.put('http://httpbin.org/status/503', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'post should raise error 503' do
      expect { @http_client.post('http://httpbin.org/status/503', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'should raise error on 404' do
      expect { @http_client.get('http://httpbin.org/status/404') }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { @http_client.delete('http://httpbin.org/status/404') }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { @http_client.put('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { @http_client.post('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
    end

    it 'should raise normal exception' do
      expect { @http_client.get('https://localhost:3005') }.to raise_error(Faraday::ConnectionFailed)
    end
  end

  describe 'Authentication' do
    before :each do
      @http_client = RestfulResource::HttpClient.new(username: 'user', password: 'passwd')
    end

    it 'should execute authenticated get' do
      response = @http_client.get('http://httpbin.org/basic-auth/user/passwd')
      expect(response.status).to eq 200
    end
  end
end
