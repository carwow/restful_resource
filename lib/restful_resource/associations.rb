module RestfulResource
  module Associations
    def has_many(nested_resource_type)
      namespace = self.to_s.deconstantize
      klass_name = "#{nested_resource_type.to_s.singularize.camelize}"
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?

      self.send(:define_method, nested_resource_type) do
        klass = klass_name.safe_constantize
        klass = RestfulResource::OpenObject if (klass.nil? || !(klass < RestfulResource::Base))
        @inner_object.send(nested_resource_type).map { |obj| klass.new(obj) }
      end
    end

    def has_one(nested_resource_type)
      namespace = self.to_s.deconstantize
      klass_name = "#{nested_resource_type.to_s.camelize}"
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?

      self.send(:define_method, nested_resource_type) do
        klass = klass_name.safe_constantize
        klass = RestfulResource::OpenObject if (klass.nil? || !(klass < RestfulResource::Base))
        nested_resource = @inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?
        klass.new(@inner_object.send(nested_resource_type))
      end
    end
  end
end
