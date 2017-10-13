module RestfulResource
  class Request
    attr_reader :body, :method, :url, :open_timeout, :timeout

    def initialize(method, url, headers: {}, body: nil, open_timeout: nil, timeout: nil)
      @method = method
      @url = url
      @headers = headers
      @body = body
      @open_timeout = open_timeout
      @timeout = timeout
    end

    def headers
      default_headers.merge(format_headers)
    end

    private

    # Formats all keys in Word-Word format
    def format_headers
      @headers.stringify_keys.each_with_object({}) do |key_with_value, headers|
        headers[format_key(key_with_value.first)] = key_with_value.last
      end
    end

    def format_key(key)
      key.humanize.split(' ').map(&:humanize).join('-')
    end

    def default_headers
      { 'Accept' => 'application/json' }
    end
  end
end

