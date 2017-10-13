module RestfulResource
  class Request
    attr_reader :body, :method, :url

    def initialize(method, url, headers: {}, body: nil)
      @method, @url, @headers, @body = method, url, headers, body
    end

    def headers
      default_headers.merge(format_headers)
    end

    private

    # Formats all keys in Word-Word format
    def format_headers
      @headers.stringify_keys.inject({}) do |h, key_with_value|
        h[format_key key_with_value.first] = key_with_value.last
        h
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

