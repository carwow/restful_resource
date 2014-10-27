module RestfulResource
  class HttpClient
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
      response = RestClient.get(url, :accept => :json, authorization: @authorization)
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
  end
end
