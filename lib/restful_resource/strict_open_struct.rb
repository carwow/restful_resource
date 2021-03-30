module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    deprecate :dig, :[], deprecator: ActiveSupport::Deprecation.new('3.0.0', 'restful_resource')
  end
end
