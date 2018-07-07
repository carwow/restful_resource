module RestfulResource
  class PromisePaginatedArray
    include RestfulResource::RescuablePromise

    def initialize(clazz, &block)
      @promise_response = Concurrent::Promise.execute { block.call }
      @clazz = clazz
    end

    def method_missing(method, *args, &block)
      promise_inner_object.send(method, *args, &block)
    end

    def wait_for_response
      promise_inner_object
    end

    private
    def promise_inner_object
      @inner_object ||= value_or_raise
    end

    def value_or_raise
      raise @promise_response.reason if @promise_response.value.nil? && @promise_response.rejected?

      response = @promise_response.value

      links = LinkHeader.parse(response.headers[:links])

      previous_page_url = links.find_link(['rel', 'prev']).try(:href)
      next_page_url = links.find_link(['rel', 'next']).try(:href)

      total_count = response.headers[:x_total_count]
      array = parse_json(response.body).map { |attributes| @clazz.new(attributes) }

      PaginatedArray.new(array, previous_page_url: previous_page_url, next_page_url: next_page_url, total_count: total_count)
    end

    def parse_json(json)
      return nil if json.strip.empty?
      ActiveSupport::JSON.decode(json)
    end
  end
end
