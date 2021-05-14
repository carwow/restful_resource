module RestfulResource
  class StrictOpenStruct < ::OpenStruct
    def self.recursively_build(attributes)
      new(attributes.transform_values do |attr|
        attr.is_a?(Hash) ? recursively_build(attr) : attr
      end)
    end

    deprecate :dig, :[]
  end
end
