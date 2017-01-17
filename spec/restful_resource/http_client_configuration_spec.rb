require_relative '../spec_helper'

describe RestfulResource::HttpClient do
  def find_middleware(adapter, name)
    adapter.builder.handlers.find {|m| m.name == name }

    rescue
      raise "Could not find Faraday middleware: #{name}"
  end

  def find_middleware_args(adapter, name)
    find_middleware(adapter, name).instance_variable_get("@args").first

    rescue
      raise "Could not find args for Faraday middleware: #{name}"
  end

  describe 'Configuration' do
    let(:connection) { described_class.new.instance_variable_get("@connection") }
    let(:middleware) { connection.builder.handlers }

    describe 'Builder configuration' do
      it 'uses the typhoeus adapter' do
        expect(middleware).to include Faraday::Adapter::Typhoeus
      end

      it 'url_encodes requests' do
        expect(middleware).to include Faraday::Request::UrlEncoded
      end

      it 'raises on any error responses' do
        expect(middleware).to include Faraday::Response::RaiseError
      end

      it 'uses utf-8 encoding' do
        expect(middleware).to include Faraday::Encoding
      end

      it 'compresses requests' do
        expect(middleware).to include FaradayMiddleware::Gzip
      end

      describe 'instrumentation' do
        context 'with the default key' do
          it 'uses default instrumenter and key' do
            expect(find_middleware_args(connection, 'FaradayMiddleware::Instrumentation')).to include(name: 'http.api')
          end
        end

        context 'with an api_name' do
          let(:connection) { described_class.new(instrumentation: { api_name: 'my_api_name'}).instance_variable_get("@connection") }

          it 'uses default instrumenter with the api_name' do
            expect(find_middleware_args(connection, 'FaradayMiddleware::Instrumentation')).to include(name: 'http.my_api_name')
          end
        end

        context 'with a custom instrumentation key' do
          let(:connection) { described_class.new(instrumentation: { request_instrument_name: 'foo.bar'}).instance_variable_get("@connection") }

          it 'uses default instrumenter with the custom key' do
            expect(find_middleware_args(connection, 'FaradayMiddleware::Instrumentation')).to include(name: 'foo.bar')
          end
        end

        context 'with a given Metrics class' do
          class FakeMetrics
            def count(name, value); end
            def sample(name, value); end
            def measure(name, value); end
          end

          let(:mock_instrumention) { instance_double(RestfulResource::Instrumentation) }

          before do
            allow(RestfulResource::Instrumentation).to receive(:new).and_return mock_instrumention
            allow(mock_instrumention).to receive(:subscribe_to_notifications)
          end

          it 'initializes the Instrumentation' do
            described_class.new(instrumentation: { app_name: 'rails', api_name: 'api', metric_class: FakeMetrics})

            expect(RestfulResource::Instrumentation).to have_received(:new)
                                               .with(app_name: 'rails',
                                                     api_name: 'api',
                                                     request_instrument_name: 'http.api',
                                                     cache_instrument_name: 'http_cache.api',
                                                     metric_class: FakeMetrics)
          end

          it 'subscribes to the notifications' do
            described_class.new(instrumentation: { app_name: 'rails', api_name: 'api', metric_class: FakeMetrics})

            expect(mock_instrumention).to have_received(:subscribe_to_notifications)
          end
        end
      end

      describe 'when provided a logger' do
        let(:connection) { described_class.new(logger: logger).instance_variable_get("@connection") }
        let(:logger) { Logger.new('/dev/null') }

        it 'uses the logger middleware' do
          expect(middleware).to include Faraday::Response::Logger
        end

        it 'uses that logger' do
          expect(find_middleware_args(connection, 'Faraday::Response::Logger')).to eq logger
        end
      end

      describe 'when provided a cache store' do
        let(:connection) { described_class.new(cache_store: 'redis').instance_variable_get("@connection") }

        it 'uses the cache_store middleware' do
          expect(middleware).to include Faraday::HttpCache
        end

        it 'uses that cache_store' do
          expect(find_middleware_args(connection, 'Faraday::HttpCache')).to include(store: 'redis')
        end

        context 'and an api_name is provided' do
          let(:connection) { described_class.new(cache_store: 'redis', instrumentation: { api_name: 'my_api_name'}).instance_variable_get("@connection") }

          it 'passes the instrumenter and the api_name' do
            expect(find_middleware_args(connection, 'Faraday::HttpCache')).to include(instrumenter: ActiveSupport::Notifications, instrument_name: 'http_cache.my_api_name')
          end
        end

        context 'and a custom instrument name is provided' do
          let(:connection) { described_class.new(cache_store: 'redis', instrumentation: { cache_instrument_name: 'foo.bar'}).instance_variable_get("@connection") }

          it 'passes the instrumenter to the http cache middleware' do
            expect(find_middleware_args(connection, 'Faraday::HttpCache')).to include(instrumenter: ActiveSupport::Notifications, instrument_name: 'foo.bar')
          end
        end
      end
    end
  end
end
