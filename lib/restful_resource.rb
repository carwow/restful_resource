require 'rack'
require 'uri'
require 'link_header'
require 'faraday'
require 'faraday_middleware'
require 'faraday-http-cache'
require 'faraday_cdn_metrics'
require 'faraday/encoding'
require 'active_support'
require 'active_support/all'
require 'resolv-replace'
require_relative 'restful_resource/version'
require_relative 'restful_resource/null_logger'
require_relative 'restful_resource/paginated_array'
require_relative 'restful_resource/parameter_missing_error'
require_relative 'restful_resource/resource_id_missing_error'
require_relative 'restful_resource/open_object'
require_relative 'restful_resource/response'
require_relative 'restful_resource/request'
require_relative 'restful_resource/http_client'
require_relative 'restful_resource/associations'
require_relative 'restful_resource/rails_validations'
require_relative 'restful_resource/redirections'
require_relative 'restful_resource/instrumentation'
require_relative 'restful_resource/base'
require_relative 'restful_resource/strict_open_struct'
require_relative 'restful_resource/railtie' if defined?(Rails::Railtie)
