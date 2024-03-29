module RestfulResource
  class Base < OpenObject
    extend RestfulResource::Associations

    Deprecator = ActiveSupport::Deprecation.new('soon', 'restful_resource')

    def self.configure(base_url: nil,
      username: nil,
      password: nil,
      auth_token: nil,
      logger: nil,
      cache_store: nil,
      instrumentation: {},
      timeout: nil,
      open_timeout: nil,
      faraday_config: nil,
      faraday_options: {},
      default_headers: {}
    )

      @base_url = URI.parse(base_url)

      @http = RestfulResource::HttpClient.new(username: username,
                                              password: password,
                                              auth_token: auth_token,
                                              logger: logger,
                                              cache_store: cache_store,
                                              timeout: timeout,
                                              open_timeout: open_timeout,
                                              instrumentation: instrumentation,
                                              faraday_config: faraday_config,
                                              faraday_options: faraday_options,
                                              default_headers: default_headers
                                             )
    end

    def self.resource_path(url)
      @resource_path = url
    end

    def self.find(id, **params)
      params_without_options, options = format_params(**params)

      response = http.get(member_url(id, **params_without_options), **options)
      new(parse_json(response.body))
    end

    def self.where(**params)
      params_without_options, options = format_params(**params)

      url = collection_url(**params_without_options)
      response = http.get(url, **options)
      paginate_response(response)
    end

    def self.get(**params)
      params_without_options, options = format_params(**params)

      response = http.get(collection_url(**params_without_options), **options)
      new(parse_json(response.body))
    end

    def self.delete(id, **params)
      params_without_options, options = format_params(**params)
      response = http.delete(member_url(id, **params_without_options), **options)
      new(parse_json(response.body))
    end

    def self.patch(id, data: {}, headers: {}, **params)
      params_without_options, options = format_params(**params)
      options.delete(:headers)

      url = member_url(id, **params_without_options)

      response = http.patch(url, data: data, headers: headers, **options)
      new(parse_json(response.body))
    end

    def self.put(id, data: {}, headers: {}, **params)
      params_without_options, options = format_params(**params)
      options.delete(:headers)

      url = member_url(id, **params_without_options)

      response = http.put(url, data: data, headers: headers, **options)
      new(parse_json(response.body))
    end

    def self.post(data: {}, headers: {}, **params)
      params_without_options, options = format_params(**params)
      options.delete(:headers)

      url = collection_url(**params_without_options)

      response = http.post(url, data: data, headers: headers, **options)

      new(parse_json(response.body))
    end

    def self.all(**params)
      where(**params)
    end

    def self.action(action_name)
      clone = self.clone
      clone.action_prefix = action_name
      clone
    end

    def self.action_prefix=(action_prefix)
      @action_prefix = action_prefix.to_s
    end

    def self.fetch_all!(conditions = {})
      Enumerator.new do |y|
        next_page = 1
        begin
          resources = where(**conditions.merge(page: next_page))
          resources.each do |resource|
            y << resource
          end
          next_page = resources.next_page
        end while !next_page.nil?
      end
    end

    def self.http
      @http || superclass.http
    end

    def self.base_url
      result = @base_url
      result = superclass.base_url if result.nil? && superclass.respond_to?(:base_url)
      raise 'Base url missing' if result.nil?

      result
    end

    def self.collection_url(**params)
      url = merge_url_paths(base_url, @resource_path, @action_prefix)
      replace_parameters(url, **params)
    end

    def self.format_params(**params)
      headers = params.delete(:headers) || {}

      headers[:cache_control] = 'no-cache' if params.delete(:no_cache)
      open_timeout = params.delete(:open_timeout)
      timeout = params.delete(:timeout)

      [params, { headers: headers, open_timeout: open_timeout, timeout: timeout }]
    end

    def self.merge_url_paths(uri, *paths)
      uri.merge(paths.compact.join('/')).to_s
    end

    def self.member_url(id, **params)
      raise ResourceIdMissingError if id.blank?

      url = merge_url_paths(base_url, @resource_path, CGI.escape(id.to_s), @action_prefix)
      replace_parameters(url, **params)
    end

    def self.new_collection(json)
      json.map do |element|
        new(element)
      end
    end

    def self.parse_json(json)
      return nil if json.strip.empty?

      ActiveSupport::JSON.decode(json)
    end

    def self.replace_parameters(url, **params)
      missing_params = []
      params = params.with_indifferent_access

      url_params = url.scan(%r{:([A-Za-z][^/]*)}).flatten
      url_params.each do |key|
        value = params.delete(key)
        if value.nil?
          missing_params << key
        else
          url = url.gsub(':' + key, CGI.escape(value.to_s))
        end
      end

      raise ParameterMissingError, missing_params if missing_params.any?

      url += "?#{params.to_query}" unless params.empty?
      url
    end

    def self.paginate_response(response)
      links_header =  response.headers[:links]
      links = LinkHeader.parse(links_header)

      prev_url = links.find_link(%w[rel prev]).try(:href)
      next_url = links.find_link(%w[rel next]).try(:href)

      array = parse_json(response.body).map { |attributes| new(attributes) }
      PaginatedArray.new(array, previous_page_url: prev_url, next_page_url: next_url, total_count: response.headers[:x_total_count])
    end
  end
end
