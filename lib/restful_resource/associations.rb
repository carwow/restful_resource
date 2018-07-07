module RestfulResource
  module Associations
    def has_many(nested_resource_type)
      namespace = self.to_s.deconstantize
      klass_name = "#{nested_resource_type.to_s.singularize.camelize.to_s}"
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?

      self.send(:define_method, nested_resource_type) do
        klass = begin
          klass_name.safe_constantize
        rescue NameError
          nil
        end
        klass = RestfulResource::PromiseOpenObject if (klass.nil? || !(klass < RestfulResource::PromiseOpenObject))
        nested_resource = promise_inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?
        nested_resource.map { |obj| klass.new(obj) }
      end
    end

    def has_one(nested_resource_type)
      namespace = self.to_s.deconstantize
      klass_name = "#{nested_resource_type.to_s.camelize.to_s}"
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?

      self.send(:define_method, nested_resource_type) do
        klass = begin
          klass_name.safe_constantize
        rescue NameError
          nil
        end
        klass = RestfulResource::PromiseOpenObject if (klass.nil? || !(klass < RestfulResource::PromiseOpenObject))
        nested_resource = promise_inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?
        klass.new(promise_inner_object.send(nested_resource_type))
      end
    end
  end
end
