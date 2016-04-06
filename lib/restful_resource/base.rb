module RestfulResource
  class Base < OpenObject
    extend RestfulResource::Associations

    def self.configure(base_url: nil,
                       username: nil,
                       password: nil,
                       logger: nil,
                       cache_store: nil)

      @base_url = URI.parse(base_url)

      @http = RestfulResource::HttpClient.new(username: username,
                                              password: password,
                                              logger: logger,
                                              cache_store: cache_store)
    end

    def self.resource_path(url)
      @resource_path = url
    end

    def self.find(id, params={})
      response = http.get(member_url(id, params))
      self.new(parse_json(response.body))
    end

    def self.where(params={})
      url = collection_url(params)
      response = http.get(url)
      self.paginate_response(response)
    end

    def self.get(params={})
      response = http.get(collection_url(params))
      RestfulResource::OpenObject.new(parse_json(response.body))
    end

    def self.delete(id, **params)
      response = http.delete(member_url(id, params))
      RestfulResource::OpenObject.new(parse_json(response.body))
    end

    def self.put(id, data: {}, **params)
      url = member_url(id, params)
      response = http.put(url, data: data)
      self.new(parse_json(response.body))
    end

    def self.post(data: {}, **params)
      url = collection_url(params)

      response = http.post(url, data: data)

      self.new(parse_json(response.body))
    end

    def self.all
      self.where
    end

    def self.action(action_name)
      clone = self.clone
      clone.action_prefix = action_name
      clone
    end

    def self.action_prefix=(action_prefix)
      @action_prefix = action_prefix.to_s
    end

    def self.fetch_all!(conditions={})
      Enumerator.new do |y|
        next_page = 1
        begin
          resources = self.where(conditions.merge(page: next_page))
          resources.each do |resource|
            y << resource
          end
          next_page = resources.next_page
        end while(!next_page.nil?)
      end
    end

    protected
    def self.http
      @http || superclass.http
    end

    def self.base_url
      result = @base_url
      if result.nil? && superclass.respond_to?(:base_url)
        result = superclass.base_url
      end
      raise "Base url missing" if result.nil?
      result
    end

    def self.collection_url(params)
      url = merge_url_paths(base_url, @resource_path, @action_prefix)
      replace_parameters(url, params)
    end

    private
    def self.merge_url_paths(uri, *paths)
      uri.merge(paths.compact.join('/')).to_s
    end

    def self.member_url(id, params)
      raise ResourceIdMissingError if id.blank?
      url = merge_url_paths(base_url, @resource_path, CGI.escape(id.to_s), @action_prefix)
      replace_parameters(url, params)
    end

    def self.new_collection(json)
      json.map do |element|
        self.new(element)
      end
    end

    def self.parse_json(json)
      return nil if json.strip.empty?
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
          url = url.gsub(':'+key, CGI.escape(value.to_s))
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
      PaginatedArray.new(array, previous_page_url: prev_url, next_page_url: next_url, total_count: response.headers[:x_total_count])
    end
  end
end
