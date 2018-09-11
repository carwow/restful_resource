module RestfulResource
  class Response
    attr_reader :body, :headers, :status

    def initialize(body: '{}', headers: {}, status: nil)
      @body = body
      @headers = headers
      @status = status
    end
  end
end
