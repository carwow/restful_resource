require 'ostruct'

module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    deprecate :dig, :[], deprecator: Base::Deprecator
  end
end
