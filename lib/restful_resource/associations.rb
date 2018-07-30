module RestfulResource
  module Associations
    def has_many(nested_resource_type)
      namespace = self.to_s.deconstantize
      klass_name = "#{nested_resource_type.to_s.singularize.camelize.to_s}"
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?
      variable_name = "@#{nested_resource_type}".to_sym

      self.send(:define_method, nested_resource_type) do
        return instance_variable_get(variable_name) if instance_variable_defined? variable_name

        klass = begin
          klass_name.safe_constantize
        rescue NameError
          nil
        end
        klass = RestfulResource::OpenObject if (klass.nil? || !(klass < RestfulResource::OpenObject))
        nested_resource = @inner_object[nested_resource_type]
        return nil if nested_resource.nil?
        result = nested_resource.map do |obj|
          case obj
          when Hash
            klass.new(obj)
          else
            obj
          end
        end

        instance_variable_set(variable_name, result)
      end
    end

    def has_one(nested_resource_type)
      namespace = self.to_s.deconstantize
      klass_name = "#{nested_resource_type.to_s.camelize.to_s}"
      klass_name = "#{namespace}::#{klass_name}" if namespace.present?
      variable_name = "@#{nested_resource_type}".to_sym

      self.send(:define_method, nested_resource_type) do
        return instance_variable_get(variable_name) if instance_variable_defined? variable_name

        klass = begin
          klass_name.safe_constantize
        rescue NameError
          nil
        end
        klass = RestfulResource::OpenObject if (klass.nil? || !(klass < RestfulResource::OpenObject))
        nested_resource = @inner_object[nested_resource_type]
        return nil if nested_resource.nil?
        result = case nested_resource
                 when Hash
                   klass.new(nested_resource)
                 else
                   nested_resource
                 end
        instance_variable_set(variable_name, result)
      end
    end
  end
end
