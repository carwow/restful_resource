require_relative '../spec_helper'

RSpec.describe RestfulResource::HttpClient do
  def faraday_connection(opts = {})
    Faraday.new(opts) do |builder|
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
    it 'executes get' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/get') { |_env| [200, {}, nil] }
      end

      response = http_client(connection).get('http://httpbin.org/get')
      expect(response.status).to eq 200
    end

    it 'executes patch' do
      connection = faraday_connection do |stubs|
        # Note: request body is serialized as url-encoded so the stub body must be in the same format to match
        stubs.patch('http://httpbin.org/patch', 'name=Alfred') { |_env| [200, {}, nil] }
      end

      response = http_client(connection).patch('http://httpbin.org/patch', data: { name: 'Alfred' })
      expect(response.status).to eq 200
    end

    it 'executes put' do
      connection = faraday_connection do |stubs|
        # Note: request body is serialized as url-encoded so the stub body must be in the same format to match
        stubs.put('http://httpbin.org/put', 'name=Alfred') { |_env| [200, {}, nil] }
      end

      response = http_client(connection).put('http://httpbin.org/put', data: { name: 'Alfred' })
      expect(response.status).to eq 200
    end

    it 'executes post' do
      connection = faraday_connection do |stubs|
        # Note: request body is serialized as url-encoded so the stub body must be in the same format to match
        stubs.post('http://httpbin.org/post', 'name=Alfred') { |_env| [200, {}, %("name": "Alfred")] }
      end

      response = http_client(connection).post('http://httpbin.org/post', data: { name: 'Alfred' })

      expect(response.body).to include 'name": "Alfred'
      expect(response.status).to eq 200
    end

    it 'executes delete' do
      connection = faraday_connection do |stubs|
        stubs.delete('http://httpbin.org/delete') { |_env| [200, {}, nil] }
      end

      response = http_client(connection).delete('http://httpbin.org/delete')

      expect(response.status).to eq 200
    end

    it 'patch should raise error 409' do
      connection = faraday_connection do |stubs|
        stubs.patch('http://httpbin.org/status/409') { |_env| [409, {}, nil] }
      end

      expect { http_client(connection).patch('http://httpbin.org/status/409') }.to raise_error(RestfulResource::HttpClient::Conflict)
    end

    it 'patch should raise error 422' do
      connection = faraday_connection do |stubs|
        stubs.patch('http://httpbin.org/status/422') { |_env| [422, {}, nil] }
      end

      expect { http_client(connection).patch('http://httpbin.org/status/422') }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'put should raise error 409' do
      connection = faraday_connection do |stubs|
        stubs.put('http://httpbin.org/status/409') { |_env| [409, {}, nil] }
      end

      expect { http_client(connection).put('http://httpbin.org/status/409') }.to raise_error(RestfulResource::HttpClient::Conflict)
    end

    it 'put should raise error 422' do
      connection = faraday_connection do |stubs|
        stubs.put('http://httpbin.org/status/422') { |_env| [422, {}, nil] }
      end

      expect { http_client(connection).put('http://httpbin.org/status/422') }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'post should raise error 422' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/422') { |_env| [422, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/422') }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'post should raise error 429' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/429') { |_env| [429, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/429') }.to raise_error(RestfulResource::HttpClient::TooManyRequests)
    end

    it 'patch should raise error 502' do
      connection = faraday_connection do |stubs|
        stubs.patch('http://httpbin.org/status/502') { |_env| [502, {}, nil] }
      end

      expect { http_client(connection).patch('http://httpbin.org/status/502') }.to raise_error(RestfulResource::HttpClient::BadGateway)
    end

    it 'put should raise error 502' do
      connection = faraday_connection do |stubs|
        stubs.put('http://httpbin.org/status/502') { |_env| [502, {}, nil] }
      end

      expect { http_client(connection).put('http://httpbin.org/status/502') }.to raise_error(RestfulResource::HttpClient::BadGateway)
    end

    it 'post should raise error 502' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/502') { |_env| [502, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/502') }.to raise_error(RestfulResource::HttpClient::BadGateway)
    end

    it 'patch should raise error 503' do
      connection = faraday_connection do |stubs|
        stubs.patch('http://httpbin.org/status/503') { |_env| [503, {}, nil] }
      end

      expect { http_client(connection).patch('http://httpbin.org/status/503') }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'put should raise error 503' do
      connection = faraday_connection do |stubs|
        stubs.put('http://httpbin.org/status/503') { |_env| [503, {}, nil] }
      end

      expect { http_client(connection).put('http://httpbin.org/status/503') }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'post should raise error 503' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/503') { |_env| [503, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/503') }.to raise_error(RestfulResource::HttpClient::ServiceUnavailable)
    end

    it 'post should raise error 504' do
      connection = faraday_connection do |stubs|
        stubs.post('http://httpbin.org/status/504') { |_env| [504, {}, nil] }
      end

      expect { http_client(connection).post('http://httpbin.org/status/504') }.to raise_error(RestfulResource::HttpClient::GatewayTimeout)
    end

    it 'raises error on 404' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/status/404') { |_env| [404, {}, nil] }
        stubs.post('http://httpbin.org/status/404') { |_env| [404, {}, nil] }
        stubs.patch('http://httpbin.org/status/404') { |_env| [404, {}, nil] }
        stubs.put('http://httpbin.org/status/404') { |_env| [404, {}, nil] }
        stubs.delete('http://httpbin.org/status/404') { |_env| [404, {}, nil] }
      end

      expect { http_client(connection).get('http://httpbin.org/status/404') }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).delete('http://httpbin.org/status/404') }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).patch('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).put('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
      expect { http_client(connection).post('http://httpbin.org/status/404', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::ResourceNotFound)
    end

    it 'raises Faraday::ConnectionFailed errors' do
      connection = faraday_connection do |stubs|
        stubs.get('https://localhost:3005') { |_env| raise Faraday::ConnectionFailed, nil }
      end

      expect { http_client(connection).get('https://localhost:3005') }.to raise_error(Faraday::ConnectionFailed)
    end

    it 'raises Timeout error' do
      connection = faraday_connection do |stubs|
        stubs.get('https://localhost:3005') { |_env| raise Faraday::TimeoutError, nil }
      end

      expect { http_client(connection).get('https://localhost:3005') }.to raise_error(RestfulResource::HttpClient::Timeout)
    end

    it 'raises ClientError when a client errors with no response' do
      connection = faraday_connection do |stubs|
        stubs.get('https://localhost:3005') { |_env| raise Faraday::ClientError, nil }
      end

      expect { http_client(connection).get('https://localhost:3005') }.to raise_error(RestfulResource::HttpClient::ClientError)
    end

    it 'raises OtherHttpError for other status response codes' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/status/418') { |_env| [418, {}, nil] }
      end

      expect { http_client(connection).get('http://httpbin.org/status/418') }.to raise_error(RestfulResource::HttpClient::OtherHttpError)
    end
  end

  describe 'Authentication' do
    describe 'Basic auth' do
      def http_client(connection)
        described_class.new(connection: connection, username: 'user', password: 'passwd')
      end

      it 'executes authenticated get' do
        connection = faraday_connection do |stubs|
          stubs.get('http://httpbin.org/basic-auth/user/passwd') { |_env| [200, {}, nil] }
        end

        response = http_client(connection).get('http://httpbin.org/basic-auth/user/passwd', headers: { 'Authorization' => 'Basic dXNlcjpwYXNzd2Q=' })

        expect(response.status).to eq 200
      end
    end

    describe 'Token auth' do
      def http_client(connection)
        described_class.new(connection: connection, auth_token: 'abc123')
      end

      it 'executes authenticated get' do
        connection = faraday_connection do |stubs|
          stubs.get('http://httpbin.org/bearer', 'Authorization' => 'Bearer abc123') { |_env| [200, {}, nil] }
        end

        response = http_client(connection).get('http://httpbin.org/bearer', headers: { 'Authorization' => 'Bearer abc123' })

        expect(response.status).to eq 200
      end
    end
  end

  describe 'Headers' do
    it 'uses custom headers' do
      connection = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/get', 'Cache-Control' => 'no-cache') { |_env| [200, {}, nil] }
      end

      response = http_client(connection).get('http://httpbin.org/get', headers: { cache_control: 'no-cache' })
      expect(response.status).to eq 200
    end
  end

  describe 'User-Agent' do
    def http_client(connection, app_name: nil)
      described_class.new(connection: connection, instrumentation: { app_name: app_name })
    end

    it 'sets a default user-agent header' do
      connection = faraday_connection do |stubs|
        user_agent = "carwow/internal RestfulResource/#{RestfulResource::VERSION} Faraday/#{Faraday::VERSION}"
        stubs.get('http://httpbin.org/get', 'User-Agent' => user_agent) { |_env| [200, {}, nil] }
      end

      response = http_client(connection).get('http://httpbin.org/get')

      expect(response.status).to eq 200
    end

    it 'sets a default user-agent header including app name' do
      connection = faraday_connection do |stubs|
        user_agent = "carwow/internal RestfulResource/#{RestfulResource::VERSION} (my-app) Faraday/#{Faraday::VERSION}"
        stubs.get('http://httpbin.org/get', 'User-Agent' => user_agent) { |_env| [200, {}, nil] }
      end

      response = http_client(connection, app_name: 'my-app').get('http://httpbin.org/get')

      expect(response.status).to eq 200
    end
  end

  describe 'X-Client-Timeout' do
    let(:http_client) { described_class.new(connection: connection, timeout: timeout) }
    let(:connection) do
      conn = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/get', required_headers) { |_env| [200, {}, nil] }
      end

      conn.options[:timeout] = timeout

      conn
    end


    context 'when explicit timeout set on connection' do
      let(:timeout) { 5 }
      let(:required_headers) { { 'X-Client-Timeout' => 5 } }
      it 'sets X-Client-Timeout correctly' do
        response = http_client.get('http://httpbin.org/get')

        expect(response.status).to eq 200
      end
    end

    context 'when not explicit timeout set' do
      let(:timeout) { nil }
      let(:required_headers) { {} }

      it 'sets X-Client-Timeout correctly' do
        response = http_client.get('http://httpbin.org/get')

        expect(response.status).to eq 200
      end
    end

    context 'when set on request' do
      let(:timeout) { nil }
      let(:required_headers) { { 'X-Client-Timeout' => 1 } }

      it 'sets X-Client-Timeout correctly' do
        response = http_client.get('http://httpbin.org/get', timeout: 1)

        expect(response.status).to eq 200
      end
    end
  end

  describe 'X-Client-Start' do
    let(:now) { Time.current }
    let(:required_headers) { { 'X-Client-Start' => (now.to_f * 1000.0).to_i } }
    let(:http_client) { described_class.new(connection: connection) }
    let(:connection) do
      conn = faraday_connection do |stubs|
        stubs.get('http://httpbin.org/get', required_headers) { |_env| [200, {}, nil] }
      end
    end

    before { allow(Time).to receive(:current).and_return(now) }

    it 'sets X-Client-Start correctly' do
      response = http_client.get('http://httpbin.org/get')

      expect(response.status).to eq 200
    end
  end
end
