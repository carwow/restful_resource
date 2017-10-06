require_relative '../spec_helper'

RSpec.describe RestfulResource::HttpClient do
  def faraday_connection
    Faraday.new do |builder|
      builder.request :url_encoded
      builder.response :raise_error
      builder.adapter :test do |stubs|
        yield stubs if block_given?
      end
    end
  end

  def http_client(connection)
    described_class.new(connection: connection)
  end

  describe 'Basic HTTP' do
    it 'should execute get' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/get') { |env| [200, {}, nil] }
      end

      response = http_client(connection).get('http://httpbin.org/get')
      expect(response.status).to eq 200
    end

    it 'should execute put' do
      connection = faraday_connection do |stubs|
        # Note: request body is serialized as url-encoded so the stub body must be in the same format to match
        stubs.put('http://httpbin.org/put', 'name=Alfred') { |env| [200, {}, nil] }
      end

      response = http_client(connection).put('http://httpbin.org/put', data: { name: 'Alfred' })
      expect(response.status).to eq 200
    end

    it 'should execute post' do
      connection = faraday_connection do |stubs|
        # Note: request body is serialized as url-encoded so the stub body must be in the same format to match
        stubs.post('http://httpbin.org/post', 'name=Alfred') { |env| [200, {}, %{"name": "Alfred"}] }
      end

      response = http_client(connection).post('http://httpbin.org/post', data: { name: 'Alfred' })

      expect(response.body).to include "name\": \"Alfred"
      expect(response.status).to eq 200
    end

    it 'should execute delete' do
      connection = faraday_connection do |stubs|
        stubs.delete('http://httpbin.org/delete') { |env| [200, {}, nil] }
      end

      response = http_client(connection).delete('http://httpbin.org/delete')

      expect(response.status).to eq 200
    end

    it 'put should raise error 422' do
      connection = faraday_connection do |stubs|
        stubs.put('http://httpbin.org/status/422') { |env| [422, {}, nil] }
      end

      expect { http_client(connection).put('http://httpbin.org/status/422') }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'post should raise error 422' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/422') { |env| [422, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/422') }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'put should raise error 503' do
      connection = faraday_connection do |stubs|
        stubs.put('http://httpbin.org/status/503') { |env| [503, {}, nil] }
      end

      expect { http_client(connection).put('http://httpbin.org/status/503') }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'post should raise error 503' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/503') { |env| [503, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/503') }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'should raise error on 404' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/status/404') { |env| [404, {}, nil] }
        stubs.post('http://httpbin.org/status/404') { |env| [404, {}, nil] }
        stubs.put('http://httpbin.org/status/404') { |env| [404, {}, nil] }
        stubs.delete('http://httpbin.org/status/404') { |env| [404, {}, nil] }
      end

      expect { http_client(connection).get('http://httpbin.org/status/404') }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).delete('http://httpbin.org/status/404') }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).put('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).post('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
    end

    it 'should raise Faraday::ConnectionFailed errors' do
      connection = faraday_connection do |stubs|
        stubs.get('https://localhost:3005') {|env| raise Faraday::ConnectionFailed.new(nil) }
      end

      expect { http_client(connection).get('https://localhost:3005') }.to raise_error(Faraday::ConnectionFailed)
    end

    it 'should raise Timeout error' do
      connection = faraday_connection do |stubs|
        stubs.get('https://localhost:3005') {|env| raise Faraday::TimeoutError.new(nil) }
      end

      expect { http_client(connection).get('https://localhost:3005') }.to raise_error(RestfulResource::HttpClient::Timeout)
    end

    it 'raises ClientError when a client errors with no response' do
      connection = faraday_connection do |stubs|
        stubs.get('https://localhost:3005') {|env| raise Faraday::ClientError.new(nil) }
      end

      expect { http_client(connection).get('https://localhost:3005') }.to raise_error(RestfulResource::HttpClient::ClientError)
    end

    it 'raises OtherHttpError for other status response codes' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/status/418') { |env| [418, {}, nil] }
      end

      expect { http_client(connection).get('http://httpbin.org/status/418') }.to raise_error(RestfulResource::HttpClient::OtherHttpError)
    end
  end

  describe 'Authentication' do
    def http_client(connection)
      described_class.new(connection: connection, username: 'user', password: 'passwd')
    end

    it 'should execute authenticated get' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/basic-auth/user/passwd') { |env| [200, {}, nil] }
      end

      response = http_client(connection).get('http://httpbin.org/basic-auth/user/passwd', headers: {"Authorization"=>"Basic dXNlcjpwYXNzd2Q="})

      expect(response.status).to eq 200
    end
  end

  describe 'Headers' do
    it 'uses custom headers' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/get', { 'Cache-Control' => 'no-cache' }) { |env| [200, {}, nil] }
      end

      response = http_client(connection).get('http://httpbin.org/get', headers: { cache_control: 'no-cache' })
      expect(response.status).to eq 200
    end
  end
end
