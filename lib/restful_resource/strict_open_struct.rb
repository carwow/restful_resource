module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    deprecate :dig, :[], deprecator: Base.deprecator
  end
end
