require 'active_support/notifications'

module RestfulResource
  class Instrumentation
    def initialize(app_name:, api_name:, request_instrument_name:, cache_instrument_name:, server_cache_instrument_name:, metric_class:)
      @app_name = app_name
      @api_name = api_name
      @request_instrument_name = request_instrument_name
      @cache_instrument_name = cache_instrument_name
      @server_cache_instrument_name = server_cache_instrument_name
      @metric_class = metric_class
    end

    attr_reader :app_name, :api_name, :request_instrument_name, :cache_instrument_name,
      :server_cache_instrument_name, :metric_class

    def subscribe_to_notifications
      validate_metric_class!

      # Subscribes to events from Faraday
      ActiveSupport::Notifications.subscribe request_instrument_name do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)

        status = status_from_event(event)

        # Outputs per API log lines like:
        # measure#quotes_site.research_site_api.time=215.161237
        # count#quotes_site.research_site_api.status.200=1
        # count#quotes_site.research_site_api.called=1
        metric_class.measure cache_notifier_namespace(metric: 'time'), event.duration
        metric_class.count cache_notifier_namespace(metric: "status.#{status}"), 1
        metric_class.count cache_notifier_namespace(metric: 'called'), 1

        # Outputs per resource log lines like:
        # measure#quotes_site.research_site_api.api_v2_cap_derivatives.time=215.161237
        # count#quotes_site.research_site_api.api_v2_cap_derivatives.status.200=1
        # count#quotes_site.research_site_api.api_v2_cap_derivatives.called=1
        metric_class.measure cache_notifier_namespace(metric: 'time', event: event), event.duration
        metric_class.count cache_notifier_namespace(metric: "status.#{status}", event: event), 1
        metric_class.count cache_notifier_namespace(metric: 'called', event: event), 1
      end

      # Subscribes to events from Faraday::HttpCache
      ActiveSupport::Notifications.subscribe cache_instrument_name do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        cache_status = event.payload.fetch(:cache_status, nil)

        # Outputs log lines like:
        # count#quotes_site.research_site_api.cache_hit=1
        # count#quotes_site.research_site_api.api_v2_cap_derivatives.cache_hit=1
        case cache_status
        when :fresh, :valid
          metric_class.count cache_notifier_namespace(metric: 'cache_hit'), 1
          metric_class.count cache_notifier_namespace(metric: 'cache_hit', event: event), 1
        when :invalid, :miss
          metric_class.count cache_notifier_namespace(metric: 'cache_miss'), 1
          metric_class.count cache_notifier_namespace(metric: 'cache_miss', event: event), 1
        when :unacceptable
          metric_class.count cache_notifier_namespace(metric: 'cache_not_cacheable'), 1
          metric_class.count cache_notifier_namespace(metric: 'cache_not_cacheable', event: event), 1
        when :bypass
          metric_class.count cache_notifier_namespace(metric: 'cache_bypass'), 1
          metric_class.count cache_notifier_namespace(metric: 'cache_bypass', event: event), 1
        end
      end

      # Subscribes to events from Faraday::Cdn::Metrics
      ActiveSupport::Notifications.subscribe server_cache_instrument_name do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        client_cache_status = event.payload.fetch(:client_cache_status, nil)
        server_cache_status = event.payload.fetch(:server_cache_status, nil)

        if client_cache_status.nil? || !client_cache_status.in?(%i[fresh valid])
          # Outputs log lines like:
          # count#quotes_site.research_site_api.server_cache_hit=1
          # count#quotes_site.research_site_api.api_v2_cap_derivatives.server_cache_hit=1
          case server_cache_status
          when :fresh
            metric_class.count cache_notifier_namespace(metric: 'server_cache_hit'), 1
            metric_class.count cache_notifier_namespace(metric: 'server_cache_hit', event: event), 1
          when :valid
            metric_class.count cache_notifier_namespace(metric: 'server_cache_hit_while_revalidate'), 1
            metric_class.count cache_notifier_namespace(metric: 'server_cache_hit_while_revalidate', event: event), 1
          when :invalid, :miss
            metric_class.count cache_notifier_namespace(metric: 'server_cache_miss'), 1
            metric_class.count cache_notifier_namespace(metric: 'server_cache_miss', event: event), 1
          when :unacceptable
            metric_class.count cache_notifier_namespace(metric: 'server_cache_not_cacheable'), 1
            metric_class.count cache_notifier_namespace(metric: 'server_cache_not_cacheable', event: event), 1
          when :bypass
            metric_class.count cache_notifier_namespace(metric: 'server_cache_bypass'), 1
            metric_class.count cache_notifier_namespace(metric: 'server_cache_bypass', event: event), 1
          when :unknown
            metric_class.count cache_notifier_namespace(metric: 'server_cache_unknown'), 1
            metric_class.count cache_notifier_namespace(metric: 'server_cache_unknown', event: event), 1
          end
        end
      end
    end

    def validate_metric_class!
      metric_methods = %i[count sample measure]
      raise ArgumentError, "Metric class '#{metric_class}' does not respond to #{metric_methods.join ','}" if metric_methods.any? { |m| !metric_class.respond_to?(m) }
    end

    def cache_notifier_namespace(metric:, event: nil)
      [app_name, api_name, base_request_path(event), metric].compact.join('.')
    end

    #  Converts a path like "/api/v2/cap_derivatives/75423/with_colours" to "api_v2_cap_derivatives_with_colours"
    def base_request_path(event)
      path_from_event(event).split('/').drop(1).select { |a| a.match(/\d+/).nil? }.join('_') if event
    end

    def path_from_event(event)
      url_from_event(event)&.path.to_s
    end

    def url_from_event(event)
      event.payload[:env]&.url || event.payload&.url
    end

    def status_from_event(event)
      event.payload[:env]&.status || event.payload&.status
    end
  end
end
