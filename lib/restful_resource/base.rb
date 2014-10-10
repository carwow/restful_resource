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

    private
    def self.member_url(id, params)
      resource_url = replace_parameters(@resource_url, params)

      @@base_url.
        merge("#{resource_url}/").
        merge(id.to_s).
        to_s
    end

    def self.parse_json(json)
      ActiveSupport::JSON.decode(json)
    end

    def self.replace_parameters(url, params)
      missing_params = []
      params = params.with_indifferent_access

      url_params = url.scan(/:([A-Za-z][^\/]*)/).flatten
      url_params.each do |key|
        value = params[key]
        if value.nil?
          missing_params << key
        else
          url = url.gsub(':'+key, value.to_s)
        end
      end

      if missing_params.any?
        raise ParameterMissingError.new(missing_params)
      end

      url
    end
  end
end
