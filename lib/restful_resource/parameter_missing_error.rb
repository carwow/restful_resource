module RestfulResource
  class ParameterMissingError < StandardError
    def initialize(missing_parameters)
      @missing_parameters = missing_parameters
    end

    def message
      "You must pass values for the following parameters: [#{@missing_parameters.join(', ')}]"
    end
  end
end
