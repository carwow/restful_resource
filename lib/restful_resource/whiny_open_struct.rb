module RestfulResource
  class WhinyOpenStruct < ::OpenStruct
    deprecate :dig, :[]
  end
end
