module RestfulResource
  module Associations
    def has_many(nested_resource_type)
      klass = nested_resource_type.to_s.singularize.camelize.safe_constantize
      klass = RestfulResource::OpenObject if (klass.nil? || (klass.superclass != RestfulResource))

      self.send(:define_method, nested_resource_type) do
        @inner_object.send(nested_resource_type).map { |obj| klass.new(obj) }
      end
    end

    def has_one(nested_resource_type)
      klass = nested_resource_type.to_s.camelize.safe_constantize
      klass = RestfulResource::OpenObject if (klass.nil? || klass.superclass != RestfulResource)

      self.send(:define_method, nested_resource_type) do
        nested_resource = @inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?
        klass.new(@inner_object.send(nested_resource_type))
      end
    end
  end
end
