# frozen_string_literal: true

module RestfulResource
  class Deprecator < ActiveSupport::Deprecation
    GEM_NAME = 'restful_resource'

    def self.build(horizon: 'soon')
      @deprecators ||= {}
      @deprecators["#{GEM_NAME}@#{horizon}"] ||= new(horizon)
    end

    def initialize(horizon)
      super(horizon, GEM_NAME)

      @app_deprecator = ActiveSupport::Deprecation.instance
    end

    # inherit the default configured behavior for the app
    delegate :behavior, to: :app_deprecator

    private

    attr_reader :app_deprecator
  end
end
