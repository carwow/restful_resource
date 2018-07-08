module RestfulResource
  class PromiseOpenObject
    include RescuablePromise

    def initialize(data = nil, &block)
      if data.nil?
        @promise_response = Concurrent::Promise.execute{ block.call }
      else
        @inner_object = process_values(data)
      end
    end

    def new_promise_open_object_member!(name) # :nodoc:
      name = name.to_sym
      unless singleton_class.method_defined?(name)
        define_singleton_method(name) { @inner_object[name] }
        define_singleton_method("#{name}=") {|x| @inner_object[name] = x}
      end
      name
    end
    private :new_promise_open_object_member!

    def method_missing(mid, *args) # :nodoc:
      len = args.length
      if mid[/.*(?==\z)/m]
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        end
      elsif len == 0 # and /\A[a-z_]\w*\z/ =~ mid #
        if promise_inner_object.key?(mid)
          new_promise_open_object_member!(mid)
          @inner_object[mid]
        else
          raise NoMethodError
        end
      else
        begin
          super
        rescue NoMethodError => err
          err.backtrace.shift
          raise
        end
      end
    end

    def respond_to?(method, include_private = false)
      super || promise_inner_object.key?(method, include_private)
    end

    def as_json(options=nil)
      promise_inner_object.as_json(options)
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
      self
    end

    protected
    def promise_inner_object
      @inner_object ||= value_or_raise
    end

    def value_or_raise
      raise @promise_response.reason if @promise_response.value.nil? && @promise_response.rejected?
      return {} if @promise_response.value.nil?
      process_values(@promise_response.value)
    end

    def process_values(values)
      values.map { |k, v| [k.to_sym, v] }.to_h
    end
  end
end
