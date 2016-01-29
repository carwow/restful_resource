module RestfulResource
  class HttpClient
    class UnprocessableEntity < StandardError
      attr_reader :response

      def initialize(response)
        @response = Response.new(body: response[:body], headers: response[:headers], status: response[:status])
      end
    end

    class ResourceNotFound < StandardError
      def message
        "404 Resource Not Found"
      end
    end

    class OtherHttpError < StandardError
      attr_reader :response

      def initialize(response)
        puts response
        @response = Response.new(body: response[:body], headers: response[:headers], status: response[:status])
      end

      def message
        "Http Error - Status code: #{response.status}"
      end
    end

    def initialize(username: nil, password: nil, logger: nil, cache_store: nil)
      @client = Faraday.new do |b|
        b.request :url_encoded
        b.response :raise_error

        if logger
          b.response :logger, logger
        end

        if cache_store
          b.user :http_cache, store: cache_store
        end

        if username.present? && password.present?
          b.basic_auth username, password
        end

        b.adapter :net_http
      end
    end

    def get(url)
      http_request(method: :get, url: url)
    end

    def delete(url)
      http_request(method: :delete, url: url)
    end

    def put(url, data: {})
      http_request(method: :put, url: url, data: data)
    end

    def post(url, data: {})
      http_request(method: :post, url: url, data: data)
    end

    private
    def http_request(method: , url: , data: nil, accept: 'application/json')
      response = @client.send(method) do |req|
        req.body = data unless data.nil?
        req.url url

        if accept
          req.headers['Accept'] = accept
        end
      end
      Response.new(body: response.body, headers: response.headers, status: response.status)
    rescue Faraday::Error::ResourceNotFound
      raise HttpClient::ResourceNotFound
    rescue Faraday::Error::ClientError => e
      response = e.response
      if response[:status] == 422
        raise HttpClient::UnprocessableEntity.new(response)
      else
        raise HttpClient::OtherHttpError.new(response)
      end
    end
  end
end
