module RestfulResource
  class OpenObject3 < OpenObject
    def initialize(attributes = {}, _hack_for_activeresource = false)
      @inner_object = StrictOpenStruct.new(attributes)
    end
  end

  class OpenObject
    def initialize(attributes = {}, _hack_for_activeresource = false)
      @inner_object = WhinyOpenStruct.new(attributes)
    end

    # All clients should migrate to using OpenObject3
    deprecate :initialize

    def method_missing(method, *args, &block)
      if @inner_object.respond_to?(method)
        @inner_object.send(method, *args, &block)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || @inner_object.respond_to?(method, include_private)
    end

    def as_json(options = nil)
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
