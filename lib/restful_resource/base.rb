module RestfulResource
  class Base < OpenObject
    extend RestfulResource::Associations

    def self.http=(http)
      @@http = http
    end

    def self.http
      @@http ||= RestfulResource::HttpClient.new(authorization: superclass.base_authorization)
    end

    def self.http_authorization(user, password)
      @base_authorization = RestfulResource::Authorization.http_authorization(user, password)
    end

    def self.base_url=(url)
      @base_url = URI.parse(url)
    end

    def self.resource_path(url)
      @resource_path = url
    end

    def self.find(id, params={})
      response = http.get(member_url(id, params))
      self.new(parse_json(response.body))
    end

    def self.where(params={})
      response = http.get(collection_url(params))
      self.paginate_response(response)
    end

    def self.get(params={})
      response = http.get(collection_url(params))
      RestfulResource::OpenObject.new(parse_json(response.body))
    end

    def self.put(id, data: {}, **params)
      response = http.put(member_url(id, params), data)
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

    def as_json(options=nil)
      @inner_object.send(:table).as_json(options)
    end

    protected
    def self.base_url
      @base_url
    end

    def self.base_authorization
      @base_authorization
    end

    private
    def self.merge_url_paths(uri, *paths)
      uri.merge(paths.compact.join('/')).to_s 
    end

    def self.member_url(id, params)
      url = merge_url_paths(superclass.base_url, @resource_path, id, @action_prefix)
      replace_parameters(url, params)
    end

    def self.collection_url(params)
      url = merge_url_paths(superclass.base_url, @resource_path, @action_prefix)  
      replace_parameters(url, params)
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
