module RestfulResource
  class PaginatedArray < Array
    def initialize(original_array, previous_page_url:, next_page_url:, total_count: )
      super(original_array)

      @previous_page_url = previous_page_url
      @next_page_url = next_page_url
      @total_count = total_count
    end

    def previous_page
      get_page_from_url(@previous_page_url)
    end

    def next_page
      get_page_from_url(@next_page_url)
    end

    def total_count
      @total_count
    end

    private
    def get_page_from_url(url)
      return nil unless url
      params = Rack::Utils.parse_query URI(url).query
      params['page'].to_i
    end
  end
end
