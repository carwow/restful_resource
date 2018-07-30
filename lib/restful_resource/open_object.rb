module RestfulResource
  class OpenObject
    def initialize(attributes = {}, _hack_for_activeresource = false)
      @inner_object = {}
      attributes.each { |k, v| @inner_object[k.to_sym] = v }
    end

    def new_enhanced_open_object_member!(name) # :nodoc:
      name = name.to_sym
      unless singleton_class.method_defined?(name)
        define_singleton_method(name) { @inner_object[name] }
        define_singleton_method("#{name}=") { |x| @inner_object[name] = x }
      end
      name
    end

    def []=(key, val)
      @inner_object[key.to_sym] = val
    end

    def [](key)
      result = @inner_object[key]
      result ||= @inner_object[key.to_sym]
      result
    end

    private :new_enhanced_open_object_member!

    def method_missing(mid, *args) # :nodoc:
      len = args.length
      if mid[/.*(?==\z)/m]
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        else
          field = mid[/.*(?==\z)/m].to_sym
          @inner_object[field] = args[0]
          new_enhanced_open_object_member!(field) unless frozen?
        end
      elsif len.zero?
        if @inner_object.key?(mid)
          new_enhanced_open_object_member!(mid) unless frozen?
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

    def dig(*args)
      @inner_object.dig(args[0].to_sym, *args[1..-1])
    end

    def respond_to?(method, include_private = false)
      super || @inner_object.key?(method)
    end

    def to_h
      @inner_object.dup
    end

    def as_json(options = nil)
      @inner_object.as_json(options)
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
