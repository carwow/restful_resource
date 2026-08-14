require 'faraday'
require 'active_support/notifications'

module RestfulResource
  # Faraday middleware that instruments requests via ActiveSupport::Notifications.
  # Replaces FaradayMiddleware::Instrumentation, which the faraday_middleware gem
  # does not ship a Faraday 2 compatible release of.
  class InstrumentationMiddleware < Faraday::Middleware
    def initialize(app, name: 'request.faraday')
      super(app)
      @name = name
    end

    def call(env)
      ActiveSupport::Notifications.instrument(@name, env) do
        @app.call(env)
      end
    end
  end
end

Faraday::Middleware.register_middleware(instrumentation: RestfulResource::InstrumentationMiddleware)
