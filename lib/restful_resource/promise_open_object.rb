module RestfulResource
  class PromiseOpenObject
    class ExceptionMatcher
      def initialize
        @matchers = {}
        @else = Proc.new{|e| raise e}
      end

      def match(exceptionClass, &block)
        @matchers[exceptionClass] = block
      end

      def else(&block)
        @else = block
      end

      def call(exception)
        result = if @matchers.has_key?(exception.class)
                   @matchers[exception.class].call(exception)
                 else
                   @else.call(exception)
                 end
        calculate_result(result)
      end

      private
      def calculate_result(result)
        if result.is_a?(Hash)
          result
        else
          nil
        end
      end
    end

    def initialize(data = nil, &block)
      if data.nil?
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

    def rescue
      matcher = ExceptionMatcher.new
      yield matcher

      @promise_response = @promise_response.rescue do |reason|
        matcher.call(reason)
      end
      self
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
