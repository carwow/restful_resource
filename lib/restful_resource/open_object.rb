module RestfulResource
  class OpenObject
    def initialize(attributes = {}, hack_for_activeresource = false)
      @inner_object = OpenStruct.new(attributes)
    end

    def method_missing(method)
      if @inner_object.respond_to?(method)
        @inner_object.send(method)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || @inner_object.respond_to?(method, include_private)
    end

    def as_json(options=nil)
      @inner_object.send(:table).as_json(options)
    end

    def ==(other)
      @inner_object == other.instance_variable_get(:@inner_object)
    end

    def eql?(other)
      @inner_object.eql?(other.instance_variable_get(:@inner_object))
    end

    def equal?(other)
      @inner_object.equal?(other.instance_variable_get(:@inner_object))
    end

    def hash
      @inner_object.hash
    end
  end
end
