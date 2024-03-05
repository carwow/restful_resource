module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    undef_method :dig, :[]
  end
end
