module RestResource
  class Base
    def self.url=(url)
      @url = url
    end

    def self.url(params={})
      url = @url
      params.keys.each do |key|
        url = url.gsub(':'+key.to_s, params[key].to_s)
      end

      url_params = url.scan(/:([^\/]+)/)
      if url_params.any?
        raise ParameterMissingError.new(url_params)
      end

      url
    end

    def self.has_one(nested_resource_type)
      klass = nested_resource_type.to_s.camelize.safe_constantize
      klass = OpenStruct if (klass.nil? || klass.superclass != RestResource)

      self.send(:define_method, nested_resource_type) do
        nested_resource = @inner_object.send(nested_resource_type)
        return nil if nested_resource.nil?
        klass.new(@inner_object.send(nested_resource_type))
      end
    end

    def self.has_many(nested_resource_type)
      klass = nested_resource_type.to_s.singularize.camelize.safe_constantize
      klass = OpenStruct if (klass.nil? || (klass.superclass != RestResource))

      self.send(:define_method, nested_resource_type) do
        @inner_object.send(nested_resource_type).map { |obj| klass.new(obj) }
      end
    end

    def initialize(attributes = {}, hack_for_activeresource = false)
      @inner_object = OpenStruct.new(attributes)
    end

    def method_missing(method, *args, &block)
      @inner_object.send(method, *args, &block)
    end

    def valid?
      errors.nil? || errors.count == g
    end

    def self.find(id, params={})
      self.new(ActiveSupport::JSON.decode(RestClient.get("#{url(params)}/#{id}")))
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
      response = RestClient.get("#{url}", params: params)
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
      PaginatableArray.new(array, previous_page_url: prev_url, next_page_url: next_url)
    end
  end
end
