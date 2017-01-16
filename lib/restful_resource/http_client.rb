# Use the Faraday-Typhoeus adapter provided by Typhoeus, not Faraday
require "typhoeus/adapters/faraday"

module RestfulResource
  class HttpClient
    class HttpError < StandardError
      attr_reader :request, :response

      def initialize(request, response = nil)
        @request, @response = request, assign_response(response)
      end

      def assign_response(response = nil)
        if response
          @response = Response.new body: response[:body], headers: response[:headers], status: response[:status]
        else
          @response = Response.new
        end
      end
    end

    class UnprocessableEntity < HttpError
    end

    class ResourceNotFound < HttpError
      def message
        "HTTP 404: Resource Not Found"
      end
    end

    class OtherHttpError < HttpError
      def message
        "HTTP Error - Status code: #{response.status}"
      end
    end

    class ServiceUnavailable < HttpError
      def message
        "HTTP 503: Service unavailable"
      end
    end

    class Timeout < HttpError
      def message
        "Timeout: Service not responding"
      end
    end

    class ClientError < HttpError
      def message
        "There was some client error"
      end
    end

    def initialize(username: nil,
                   password: nil,
                   logger: nil,
                   cache_store: nil,
                   connection: nil,
                   instrumentation: {})


      api_name = instrumentation[:api_name]     ||= 'api'
      instrumentation[:request_instrument_name] ||= "http.#{api_name}"
      instrumentation[:cache_instrument_name]   ||= "http_cache.#{api_name}"

      if instrumentation[:metric_class]
        @metrics = Instrumentation.new(instrumentation.slice(:app_name, :api_name, :request_instrument_name, :cache_instrument_name, :metric_class))
        @metrics.subscribe_to_notifications
      end

      # Use a provided faraday client or initalize a new one
      @connection = connection || initialize_connection(logger: logger,
                                                        cache_store: cache_store,
                                                        instrumenter: ActiveSupport::Notifications,
                                                        request_instrument_name: instrumentation.fetch(:request_instrument_name, nil),
                                                        cache_instrument_name: instrumentation.fetch(:cache_instrument_name, nil))

      if username && password
        @connection.basic_auth username, password
      end
    end

    def get(url, accept: 'application/json')
      http_request(Request.new(:get, url, accept: accept))
    end

    def delete(url, accept: 'application/json')
      http_request(Request.new(:delete, url, accept: accept))
    end

    def put(url, data: {}, accept: 'application/json')
      http_request(Request.new(:put, url, body: data, accept: accept))
    end

    def post(url, data: {}, accept: 'application/json')
      http_request(Request.new(:post, url, body: data, accept: accept))
    end

    private

    def initialize_connection(logger: nil,
                              cache_store: nil,
                              instrumenter: nil,
                              request_instrument_name: nil,
                              cache_instrument_name: nil)

      @connection = Faraday.new do |b|
        b.request :url_encoded
        b.response :raise_error

        if logger
          b.response :logger, logger
        end

        if cache_store
          b.use :http_cache, store: cache_store,
                             logger: logger,
                             instrumenter: instrumenter,
                             instrument_name: cache_instrument_name
        end

        if instrumenter && request_instrument_name
          b.use :instrumentation, name: request_instrument_name
        end

        b.response :encoding
        b.use :gzip

        b.adapter :typhoeus
      end
    end

    def http_request(request)
      response = @connection.send(request.method) do |req|
        req.options.open_timeout = 2 # seconds
        req.options.timeout = 10 # seconds

        req.body = request.body unless request.body.nil?
        req.url request.url

        if request.accept
          req.headers['Accept'] = request.accept
        end
      end
      Response.new(body: response.body, headers: response.headers, status: response.status)
    rescue Faraday::ConnectionFailed
      raise
    rescue Faraday::TimeoutError
      raise HttpClient::Timeout.new(request)
    rescue Faraday::ClientError => e
      response = e.response
      raise ClientError.new(request) unless response
      case response[:status]
      when 404 then raise HttpClient::ResourceNotFound.new(request, response)
      when 422 then raise HttpClient::UnprocessableEntity.new(request, response)
      when 503 then raise HttpClient::ServiceUnavailable.new(request, response)
      else raise HttpClient::OtherHttpError.new(request, response)
      end
    end
  end
end
