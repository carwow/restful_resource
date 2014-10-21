module RestfulResource
  class Base < OpenObject
    def self.http=(http)
      @@http = http
    end

    def self.http
      @@http ||= RestfulResource::HttpClient.new()
    end

    def self.base_url=(url)
      puts "base_url=(#{url}) -> #{self.to_s}"
      @base_url = URI.parse(url)
    end

    def self.base_url
      @base_url
    end

    def self.resource_url=(url)
      @resource_url = url
    end

    def self.find(id, params={})
      response = http.get(member_url(id, params))
      self.new(parse_json(response.body))
    end

    def self.where(params={})
      response = http.get(collection_url(params))
      self.paginate_response(response)
    end

    private
    def self.member_url(id, params)
      replace_parameters(superclass.base_url.merge("#{@resource_url}/").merge(id.to_s).to_s, params)
    end

    def self.collection_url(params)
      replace_parameters(superclass.base_url.merge("#{@resource_url}/").to_s, params)
    end

    def self.new_collection(json)
      json.map do |element|
        self.new(element)
      end
    end

    def self.parse_json(json)
      ActiveSupport::JSON.decode(json)
    end

    def self.replace_parameters(url, params)
      missing_params = []
      params = params.with_indifferent_access

      url_params = url.scan(/:([A-Za-z][^\/]*)/).flatten
      url_params.each do |key|
        value = params.delete(key)
        if value.nil?
          missing_params << key
        else
          url = url.gsub(':'+key, value.to_s)
        end
      end

      if missing_params.any?
        raise ParameterMissingError.new(missing_params)
      end

      url = url + "?#{params.to_query}" unless params.empty?
      url
    end

    def self.paginate_response(response)
      links_header =  response.headers[:links]
      links = LinkHeader.parse(links_header)

      prev_url = links.find_link(['rel', 'prev']).try(:href)
      next_url = links.find_link(['rel', 'next']).try(:href)

      array = parse_json(response.body).map { |attributes| self.new(attributes) }
      PaginatedArray.new(array, previous_page_url: prev_url, next_page_url: next_url)
    end
  end
end
