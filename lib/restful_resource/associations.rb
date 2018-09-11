module RestfulResource
  module Associations
    def has_many(nested_resource_type)
      namespace = to_s.deconstantize
      klass_name = nested_resource_type.to_s.singularize.camelize.to_s
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?

      send(:define_method, nested_resource_type) do
        klass = begin
          klass_name.safe_constantize
        rescue NameError
          nil
        end
        klass = RestfulResource::OpenObject if klass.nil? || !(klass < RestfulResource::OpenObject)
        nested_resource = @inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?

        nested_resource.map { |obj| klass.new(obj) }
      end
    end

    def has_one(nested_resource_type)
      namespace = to_s.deconstantize
      klass_name = nested_resource_type.to_s.camelize.to_s
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?

      send(:define_method, nested_resource_type) do
        klass = begin
          klass_name.safe_constantize
        rescue NameError
          nil
        end
        klass = RestfulResource::OpenObject if klass.nil? || !(klass < RestfulResource::OpenObject)
        nested_resource = @inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?

        klass.new(@inner_object.send(nested_resource_type))
      end
    end
  end
end
