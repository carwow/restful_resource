module RestfulResource
  class StrictOpenObject < ::OpenObject
    alias [] fetch
    undef_method :dig
  end
end
