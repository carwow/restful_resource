module RestfulResource
  class HttpClient
    def get(url)
      RestClient.get(url, :accept => :json)
    end
  end
end
