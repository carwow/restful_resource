require 'concurrent'

module RestfulResource
  class FutureResponse
    def initialize(connection, request)
      @future = Concurrent::Future.execute do
        begin
          connection.send(request.method) do |req|
            req.options.open_timeout = request.open_timeout || 10 # seconds
            req.options.timeout = request.timeout || 10 # seconds

            req.body = request.body unless request.body.nil?
            req.url request.url

            req.headers = req.headers.merge(request.headers)
          end
        rescue Faraday::ConnectionFailed
          raise
        rescue Faraday::TimeoutError
          raise HttpClient::Timeout.new(request)
        rescue Faraday::ClientError => e
          response = e.response
          raise HttpClient::ClientError.new(request) unless response
          case response[:status]
          when 404 then raise HttpClient::ResourceNotFound.new(request, response)
          when 422 then raise HttpClient::UnprocessableEntity.new(request, response)
          when 502 then raise HttpClient::BadGateway.new(request, response)
          when 503 then raise HttpClient::ServiceUnavailable.new(request, response)
          else raise HttpClient::OtherHttpError.new(request, response)
          end
        end
      end
    end

    def method_missing(method, *args, &block)
      @response ||= @future.value
      raise @future.reason if @future.rejected?

      r = Response.new(body: @response.body, headers: @response.headers, status: @response.status)
      r.send(method)
    end
  end
end
