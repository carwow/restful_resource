module RestfulResource
  module RailsValidations
    module ClassMethods
      def put(id, data: {}, **params)
        begin
          super(id, data: data, **params)
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

      def post(data: {}, **params)
        begin
          super(data: data, **params)
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
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def valid?
      @inner_object.errors.nil?
    end
  end
end
