module RestfulResource
  module RailsValidations
    module ClassMethods
      def put(id, data: {}, **)
        @put_validation_result_id = id
        super
      end

      def errors
        if future_value.rejected?
          e = future_value.reason
          errors = parse_json(e.response.body)
          result = nil
          if errors.is_a?(Hash) && errors.has_key?('errors')
            result = data.merge(errors)
          else
            result = data.merge(errors: errors)
          end

          result = result.merge(id: @put_validation_result_id) unless @put_validation_result_id.nil?
          self.new(result)
        else
          nil
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def valid?
      future_inner_object.errors.nil?
    end
  end
end
