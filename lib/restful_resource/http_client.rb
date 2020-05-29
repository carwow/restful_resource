# Use the Faraday-Typhoeus adapter provided by Typhoeus, not Faraday
require 'typhoeus/adapters/faraday'

module RestfulResource
  class HttpClient
    class HttpError < StandardError
      attr_reader :request, :response

      def initialize(request, response = nil)
        @request = request
        @response = assign_response(response)
      end

      def assign_response(response = nil)
        @response = if response
                      Response.new(body: response[:body], headers: response[:headers], status: response[:status])
                    else
                      Response.new
                    end
      end
    end

    class UnprocessableEntity < HttpError
    end

    class ResourceNotFound < HttpError
      def message
        'HTTP 404: Resource Not Found'
      end
    end

    class Conflict < HttpError; end

    class RetryableError < HttpError; end

    class OtherHttpError < HttpError
      def message
        "HTTP Error - Status code: #{response.status}"
      end
    end

    class BadGateway < RetryableError
      def message
        'HTTP 502: Bad gateway'
      end
    end

    class ServiceUnavailable < RetryableError
      def message
        'HTTP 503: Service unavailable'
      end
    end

    class GatewayTimeout < RetryableError
      def message
        'HTTP 504: Gateway timeout'
      end
    end

    class Timeout < RetryableError
      def message
        'Timeout: Service not responding'
      end
    end

    class TooManyRequests < RetryableError
      def message
        'HTTP 429: Too Many Requests'
      end
    end

    class ClientError < RetryableError
      def message
        'There was some client error'
      end
    end

    DEFAULT_TIMEOUT_IN_SECS = 10
    DEFAULT_OPEN_TIMEOUT_IN_SECS = 2

    def initialize(username: nil,
      password: nil,
      auth_token: nil,
      logger: nil,
      cache_store: nil,
      connection: nil,
      instrumentation: {},
      timeout: nil,
      open_timeout: nil,
      faraday_config: nil,
      faraday_options: {})
      api_name = instrumentation[:api_name]            ||= 'api'
      instrumentation[:request_instrument_name]        ||= "http.#{api_name}"
      instrumentation[:cache_instrument_name]          ||= "http_cache.#{api_name}"

      if instrumentation[:metric_class]
        @metrics = Instrumentation.new(instrumentation.slice(:app_name,
          :api_name,
          :request_instrument_name,
          :cache_instrument_name,
          :metric_class
        )
                                      )
        @metrics.subscribe_to_notifications
      end

      # Use a provided faraday client or initalize a new one
      @connection = connection || initialize_connection(logger: logger,
                                                        cache_store: cache_store,
                                                        instrumenter: ActiveSupport::Notifications,
                                                        timeout: timeout,
                                                        open_timeout: open_timeout,
                                                        request_instrument_name: instrumentation.fetch(:request_instrument_name, nil),
                                                        cache_instrument_name: instrumentation.fetch(:cache_instrument_name, nil),
                                                        faraday_config: faraday_config,
                                                        faraday_options: faraday_options
                                                       )

      if auth_token
        @connection.headers[:authorization] = "Bearer #{auth_token}"
      elsif username && password
        @connection.basic_auth(username, password)
      end

      @connection.headers[:user_agent] = build_user_agent(instrumentation[:app_name])
    end

    def get(url, headers: {}, open_timeout: nil, timeout: nil)
      http_request(
        Request.new(
          :get,
          url,
          headers: headers,
          open_timeout: open_timeout,
          timeout: timeout
        )
      )
    end

    def delete(url, headers: {}, open_timeout: nil, timeout: nil)
      http_request(
        Request.new(
          :delete,
          url,
          headers: headers,
          open_timeout: open_timeout,
          timeout: timeout
        )
      )
    end

    def patch(url, data: {}, headers: {}, open_timeout: nil, timeout: nil)
      http_request(
        Request.new(
          :patch,
          url,
          body: data,
          headers: headers,
          open_timeout: open_timeout,
          timeout: timeout
        )
      )
    end

    def put(url, data: {}, headers: {}, open_timeout: nil, timeout: nil)
      http_request(
        Request.new(
          :put,
          url,
          body: data,
          headers: headers,
          open_timeout: open_timeout,
          timeout: timeout
        )
      )
    end

    def post(url, data: {}, headers: {}, open_timeout: nil, timeout: nil)
      http_request(
        Request.new(
          :post,
          url,
          body: data,
          headers: headers,
          open_timeout: open_timeout,
          timeout: timeout
        )
      )
    end

    private

    def initialize_connection(logger: nil,
      cache_store: nil,
      instrumenter: nil,
      timeout: nil,
      open_timeout: nil,
      request_instrument_name: nil,
      cache_instrument_name: nil,
      faraday_config: nil,
      faraday_options: {})

      @connection = Faraday.new(nil, faraday_options) do |b|
        b.request :json
        b.response :raise_error

        b.response :logger, logger if logger

        if cache_store
          b.use :http_cache, store: cache_store,
                             logger: logger,
                             instrumenter: instrumenter,
                             instrument_name: cache_instrument_name
        end

        b.use :instrumentation, name: request_instrument_name if instrumenter && request_instrument_name

        b.options.timeout = timeout || DEFAULT_TIMEOUT_IN_SECS
        b.options.open_timeout = open_timeout || DEFAULT_OPEN_TIMEOUT_IN_SECS

        faraday_config&.call(b)

        b.response :encoding
        b.use :gzip

        b.adapter :typhoeus
      end
    end

    def build_user_agent(app_name)
      parts = ['carwow/internal']
      parts << "RestfulResource/#{VERSION}"
      parts << "(#{app_name})" if app_name
      parts << "Faraday/#{Faraday::VERSION}"
      parts.join(' ')
    end

    def http_request(request)
      response = @connection.send(request.method) do |req|
        req.options.timeout = request.timeout if request.timeout
        req.options.open_timeout = request.open_timeout if request.open_timeout

        req.body = request.body unless request.body.nil?
        req.url request.url

        req.headers = req.headers.merge(request.headers).merge(x_client_start: time_current_ms)
        req.headers = req.headers.merge(x_client_timeout: req.options[:timeout]) if req.options[:timeout]
      end

      Response.new(body: response.body, headers: response.headers, status: response.status)
    rescue Faraday::ConnectionFailed
      raise
    rescue Faraday::TimeoutError
      raise HttpClient::Timeout, request
    rescue Faraday::ClientError => e
      response = e.response
      raise ClientError, request unless response

      handle_error(request, response)
    rescue Faraday::ServerError => e
      response = e.response
      raise ClientError, request unless response

      handle_error(request, response)
    end

    def handle_error(request, response)
      case response[:status]
      when 404 then raise HttpClient::ResourceNotFound.new(request, response)
      when 409 then raise HttpClient::Conflict.new(request, response)
      when 422 then raise HttpClient::UnprocessableEntity.new(request, response)
      when 429 then raise HttpClient::TooManyRequests.new(request, response)
      when 502 then raise HttpClient::BadGateway.new(request, response)
      when 503 then raise HttpClient::ServiceUnavailable.new(request, response)
      when 504 then raise HttpClient::GatewayTimeout.new(request, response)
      else raise HttpClient::OtherHttpError.new(request, response)
      end
    end

    def time_current_ms
      (Time.current.to_f * 1_000.0).to_i
    end
  end
end
