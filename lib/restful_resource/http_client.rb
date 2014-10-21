module RestfulResource
  class HttpClient
    def get(url)
      response = RestClient.get(url, :accept => :json)
      Response.new(body: response.body, headers: response.headers)
    end
  end
end
