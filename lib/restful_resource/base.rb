module RestfulResource
  class Base
    def self.url=(url)
      @url = url
    end

    def self.processed_url_and_params(params={})
      url = @url
      other_params = params.clone
      missing_params = []

      url_params = url.scan(/:([A-Za-z][^\/]*)/).flatten
      url_params.each do |key|
        value = other_params.delete(key.to_sym)
        if value.nil?
          missing_params << key
        else
          url = url.gsub(':'+key.to_s, value.to_s)
        end
      end

      if missing_params.any?
        raise ParameterMissingError.new(missing_params)
      end

      [url, other_params]
    end

    def self.url(params={})
      processed_url_and_params(params).first
    end


    def self.has_one(nested_resource_type)
      klass = nested_resource_type.to_s.camelize.safe_constantize
      klass = OpenStruct if (klass.nil? || klass.superclass != RestfulResource)

      self.send(:define_method, nested_resource_type) do
        nested_resource = @inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?
        klass.new(@inner_object.send(nested_resource_type))
      end
    end

    def self.has_many(nested_resource_type)
      klass = nested_resource_type.to_s.singularize.camelize.safe_constantize
      klass = OpenStruct if (klass.nil? || (klass.superclass != RestfulResource))

      self.send(:define_method, nested_resource_type) do
        @inner_object.send(nested_resource_type).map { |obj| klass.new(obj) }
      end
    end

    def initialize(attributes = {}, hack_for_activeresource = false)
      @inner_object = OpenStruct.new(attributes)
    end

    def method_missing(method)
      if @inner_object.respond_to?(method)
        @inner_object.send(method)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || @inner_object.respond_to?(method, include_private)
    end

    def valid?
      errors.nil? || errors.count == g
    end

    def self.find(id, url_params={})
      response = RestClient.get("#{url(url_params)}/#{id}", params: {})
      self.new(ActiveSupport::JSON.decode(response))
    end

    def self.get_one(url_params={})
      resource = create_new_resource(url_params)
      response = resource.get
      self.new(ActiveSupport::JSON.decode(response))      
    end

    def self.update_attributes(id, attributes)
      begin
        result = parse(RestClient.put("#{url}/#{id}", attributes))
      rescue RestClient::UnprocessableEntity => e
        errors = parse(e.response)
        result = attributes.merge(errors: errors)
      end
      self.new(result)
    end

    def self.create(attributes)
      begin
        result = parse(RestClient.post("#{url}", attributes))
      rescue RestClient::UnprocessableEntity => e
        errors = parse(e.response)
        result = attributes.merge(errors: errors)
      end
      self.new(result)
    end

    def self.search(params = {})
      response = RestClient.get("#{url}/search", params: params)
      paginate_response(response)
    end

    def self.all(params = {})
      resource = create_new_resource(params)
      response = resource.get
      paginate_response(response)
    end

    def self.get(postfix_url = "", params = {})
      response = RestClient.get("#{url}#{postfix_url}", params: params)
      paginate_response(response)
    end

    def self.put(postfix_url = "", params = {})
      response = RestClient.put("#{url}#{postfix_url}", params)
    end

    def self.post(postfix_url = "", params = {})
      response = RestClient.post("#{url}#{postfix_url}", params)
    end

    def self.all_not_paginated
      page = 1
      results = []
      while page
        page_data = self.all(page: page);
        results += page_data
        page = page_data.next_page
      end

      results
    end

    def self.parse(json)
      ActiveSupport::JSON.decode(json)
    end

    def to_json(*args)
      @inner_object.send(:table).to_json(*args)
    end

    def as_json(*)
      @inner_object.send(:table).as_json
    end

    private
    def self.paginate_response(response)
      links_header =  response.headers[:links]
      links = LinkHeader.parse(links_header)

      prev_url = links.find_link(['rel', 'prev']).try(:href)
      next_url = links.find_link(['rel', 'next']).try(:href)

      array = ActiveSupport::JSON.decode(response).map { |attributes| self.new(attributes) }
      PaginatedArray.new(array, previous_page_url: prev_url, next_page_url: next_url)
    end

    def self.create_new_resource(params={})
      url, other_params = processed_url_and_params(params)
      url += "?#{other_params.to_query}" if not other_params.empty?
      resource = RestClient::Resource.new("#{url}")
    end

  end
end
