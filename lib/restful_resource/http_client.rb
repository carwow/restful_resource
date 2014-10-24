module RestfulResource
  class HttpClient
    def initialize(authorization: nil)
      @authorization = authorization
    end

    def get(url)
      response = RestClient.get(url, :accept => :json, authorization: @authorization)
      Response.new(body: response.body, headers: response.headers, status: response.code)
    end

    def put(url, data: {})
      response = RestClient.put(url, data, :accept => :json, authorization: @authorization)
      Response.new(body: response.body, headers: response.headers, status: response.code)
    end
  end
end
