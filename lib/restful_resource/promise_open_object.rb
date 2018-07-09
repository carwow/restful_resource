module RestfulResource
  class PromiseOpenObject
    include RescuablePromise

    def initialize(data = nil, &block)
      if block_given?
        @promise_response = Concurrent::Promise.execute{ block.call }
      else
        @inner_object = OpenStruct.new(data)
      end
    end

    def method_missing(method, *args, &block)
      if promise_inner_object.respond_to?(method)
        promise_inner_object.send(method, *args, &block)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || promise_inner_object.respond_to?(method, include_private)
    end

    def as_json(options=nil)
      promise_inner_object.send(:table).as_json(options)
    end

    def ==(other)
      promise_inner_object == other.send(:promise_inner_object)
    end

    def [](key)
      promise_inner_object[key]
    end

    def []=(key, value)
      promise_inner_object[key] = value
    end

    def eql?(other)
      promise_inner_object.eql?(other.send(:promise_inner_object))
    end

    def equal?(other)
      promise_inner_object.equal?(other.send(:promise_inner_object))
    end

    def hash
      promise_inner_object.hash
    end

    def wait_for_response
      promise_inner_object
    end

    protected
    def promise_inner_object
      @inner_object ||= value_or_raise
    end

    def value_or_raise
      raise @promise_response.reason if @promise_response.value.nil? && @promise_response.rejected?
      OpenStruct.new(@promise_response.value)
    end
  end
end
