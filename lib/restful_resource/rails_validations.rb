module RestfulResource
  module RailsValidations
    module ClassMethods
      def put(id, data: {}, **)
        super
      rescue HttpClient::UnprocessableEntity => e
        errors = parse_json(e.response.body)
        result = nil
        if errors.is_a?(Hash) && errors.has_key?('errors')
          result = data.merge(errors)
        else
          result = data.merge(errors: errors)
        end
        result = result.merge(id: id)
        self.new(result)
      end

      def post(data: {}, **)
        with_validations(data: data) { super }
      end

      def get(*)
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
          self.new(result)
        else
          nil
        end
      end

      private

      def with_validations(data: {})
        yield
      rescue HttpClient::UnprocessableEntity => e
        errors = parse_json(e.response.body)
        result = nil
        if errors.is_a?(Hash) && errors.has_key?('errors')
          result = data.merge(errors)
        else
          result = data.merge(errors: errors)
        end
        self.new(result)
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
