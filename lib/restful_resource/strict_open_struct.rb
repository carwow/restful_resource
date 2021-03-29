module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    deprecate :dig, :[]
  end
end
