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
      it 'uses the excon adapter' do
        expect(middleware).to include Faraday::Adapter::Excon
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
      end
    end

    describe 'Excon Adapter configuration' do
      let(:config) { find_middleware_args connection, 'Faraday::Adapter::Excon' }
    
      it 'uses nonblock' do
        expect(config[:nonblock]).to eq true
      end

      it 'uses a persistent connection' do
        expect(config[:persistent]).to eq true
      end

      it 'has a connect_timeout of 2' do
        expect(config[:connect_timeout]).to eq 2
      end

      it 'has a read_timeout of 10' do
        expect(config[:read_timeout]).to eq 10
      end

      it 'has a write_timeout of 2' do
        expect(config[:write_timeout]).to eq 2
      end
    end
  end
end