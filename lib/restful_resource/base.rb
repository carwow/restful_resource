module RestfulResource
  class Base < OpenObject
    def self.http=(http)
      @@http = http
    end

    def self.http
      @@http || RestfulResource::HttpClient.new()
    end

    def self.base_url=(url)
      @@base_url = URI.parse(url)
    end

    def self.resource_url=(url)
      @resource_url = url
    end

    def self.find(id, params={})
      response = http.get(member_url(id, params))
      self.new(parse_json(response))
    end

    def self.where(params={})
      response = http.get(collection_url(params))
      self.new_collection(parse_json(response))
    end

    private
    def self.member_url(id, params)
      replace_parameters(@@base_url.merge("#{@resource_url}/").merge(id.to_s).to_s, params)
    end

    def self.collection_url(params)
      replace_parameters(@@base_url.merge("#{@resource_url}/").to_s, params)
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
  end
end
