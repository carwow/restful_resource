module RestfulResource
  class Response
    attr_reader :body, :headers

    def initialize(body: "{}", headers: {})
      @body, @headers = body, headers
    end
  end
end
