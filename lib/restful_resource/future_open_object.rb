module RestfulResource
  class FutureOpenObject
    def initialize(data = nil, &block)
      if data.nil?
        @future_response = Concurrent::Future.execute{ block.call }
      else
        @inner_object = OpenStruct.new(data)
      end
    end
    #def initialize(attributes = {}, hack_for_activeresource = false)
    #  @inner_object = OpenStruct.new(attributes)
    #end

    def method_missing(method, *args, &block)
      if future_inner_object.respond_to?(method)
        future_inner_object.send(method, *args, &block)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || future_inner_object.respond_to?(method, include_private)
    end

    def as_json(options=nil)
      future_inner_object.send(:table).as_json(options)
    end

    def ==(other)
      future_inner_object == other.send(:future_inner_object)
    end

    def eql?(other)
      future_inner_object.eql?(other.send(:future_inner_object))
    end

    def equal?(other)
      future_inner_object.equal?(other.send(:future_inner_object))
    end

    def hash
      future_inner_object.hash
    end

    private
    def future_inner_object
      @inner_object ||= OpenStruct.new(future_value)
    end

    def future_value
      @future_response.value
    end
  end
end
