module RestfulResource
  module RailsValidations
    module ClassMethods
      def put(id, data: {}, **params)
        begin
          super(id, data: data, **params)
        rescue HttpClient::UnprocessableEntity => e
          errors = parse_json(e.response.body)
          result = data.merge(errors)
          self.new(result)
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def valid?
      @inner_object.errors.nil? || @inner_object.errors.count == 0
    end
  end
end
