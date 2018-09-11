module RestfulResource
  module RailsValidations
    module ClassMethods
      def put(id, data: {}, **)
        super
      rescue HttpClient::UnprocessableEntity => e
        errors = parse_json(e.response.body)
        result = nil
        result = if errors.is_a?(Hash) && errors.key?('errors')
                   data.merge(errors)
                 else
                   data.merge(errors: errors)
                 end
        result = result.merge(id: id)
        new(result)
      end

      def post(data: {}, **)
        with_validations(data: data) { super }
      end

      def get(*)
        with_validations { super }
      end

      private

      def with_validations(data: {})
        yield
      rescue HttpClient::UnprocessableEntity => e
        errors = parse_json(e.response.body)
        result = nil
        result = if errors.is_a?(Hash) && errors.key?('errors')
                   data.merge(errors)
                 else
                   data.merge(errors: errors)
                 end
        new(result)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def valid?
      @inner_object.errors.nil?
    end
  end
end
