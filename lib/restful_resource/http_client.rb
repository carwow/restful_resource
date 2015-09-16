module RestfulResource
  class HttpClient
    class UnknownError < StandardError; end
    class UnprocessableEntity < RuntimeError
      attr_reader :response

      def initialize(response)
        @response = Response.new(body: response.body, headers: response.headers, status: response.code)
      end
    end

    def initialize(authorization: nil)
      @authorization = authorization
    end

    def get(url)
      request_resource(url) do
        response = RestClient.get(url, :accept => :json, authorization: @authorization)
        Response.new(body: response.body, headers: response.headers, status: response.code)
      end
    end

    def delete(url)
      response = RestClient.delete(url, :accept => :json, authorization: @authorization)
      Response.new(body: response.body, headers: response.headers, status: response.code)
    end

    def put(url, data: {})
      begin
        response = RestClient.put(url, data, :accept => :json, authorization: @authorization)
      rescue RestClient::UnprocessableEntity => e
        raise HttpClient::UnprocessableEntity.new(e.response)
      end
      Response.new(body: response.body, headers: response.headers, status: response.code)
    end

    def post(url, data: {})
      begin
        response = RestClient.post(url, data, :accept => :json, authorization: @authorization)
      rescue RestClient::UnprocessableEntity => e
        raise HttpClient::UnprocessableEntity.new(e.response)
      end
      Response.new(body: response.body, headers: response.headers, status: response.code)
    end

    private

    def request_resource(url, &block)
      block.call
    rescue NoMethodError => e
      if e.message.include?('each')
        message = "#{url}: failed with #{e.message}"
        raise HttpClient::UnknownError.new(message)
      else
        raise e
      end
    end
  end
end
