module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    deprecate :dig, :[], deprecator: Deprecator.build
  end
end
