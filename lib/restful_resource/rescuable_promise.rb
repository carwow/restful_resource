module RestfulResource
  module RescuablePromise
    def rescue
      matcher = ExceptionMatcher.new
      yield matcher

      @promise_response = @promise_response.rescue do |reason|
        matcher.call(reason)
      end
      self
    end

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
        elsif result.is_a?(Array)
          result
        else
          nil
        end
      end
    end
  end
end
