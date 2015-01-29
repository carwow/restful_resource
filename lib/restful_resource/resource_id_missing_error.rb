module RestfulResource
  class ResourceIdMissingError < StandardError
    def message
      "You must pass the resource ID"
    end
  end
end
