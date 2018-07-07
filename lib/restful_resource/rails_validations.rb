module RestfulResource
  module RailsValidations
    module ClassMethods
      def put(id, data: {}, **)
        with_validations(id: id, data: data) { super }
      end

      def post(data: {}, **)
        with_validations(data: data) { super }
      end

      def get(*)
        with_validations { super }
      end

      private

      def with_validations(id: nil, data: {})
        yield.rescue do |e|
          if e.class == HttpClient::UnprocessableEntity
            errors = parse_json(e.response.body)
            result = nil
            if errors.is_a?(Hash) && errors.has_key?('errors')
              result = data.merge(errors)
            else
              result = data.merge(errors: errors)
            end
            result = result.merge(id: id) unless id.nil?
            @inner_object = result
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def valid?
      promise_inner_object.errors.nil?
    end
  end
end
