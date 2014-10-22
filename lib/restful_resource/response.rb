module RestfulResource
  class Response
    attr_reader :body, :headers, :status

    def initialize(body: "{}", headers: {}, status: nil)
      @body, @headers, @status = body, headers, status
    end
  end
end
