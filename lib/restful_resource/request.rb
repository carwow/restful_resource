module RestfulResource
  class Request
    attr_reader :body, :method, :url, :accept

    def initialize(method, url, accept: 'application/json', body: nil)
      @method, @url, @accept, @body = method, url, accept, body
    end
  end
end

