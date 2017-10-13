module RestfulResource
  class MaximumAttemptsReached < StandardError
    def message
      "The maximum attempts limit was reached before the resource was ready"
    end
  end

  module Redirections
    def self.included(base)
      base.instance_eval do
        def post(data: {}, delay: 1.0, max_attempts: 10, headers: {}, open_timeout: nil, timeout: nil, **params)
          url = collection_url(params)

          response = self.accept_redirected_result(response: http.post(url, data: data, headers: headers, open_timeout: nil, timeout: nil), delay: delay, max_attempts: max_attempts)

          self.new(parse_json(response.body))
        end

        private
        def self.accept_redirected_result(response:, delay:, max_attempts:)
          new_response = response
          if response.status == 303
            attempts = 0
            resource_location = response.headers[:location]

            RestfulResource::Redirections.wait(delay)
            new_response = http.get(resource_location, headers: {}, open_timeout: nil, timeout: nil)

            while (new_response.status == 202) && (attempts < max_attempts)
              attempts += 1
              RestfulResource::Redirections.wait(delay)
              new_response = http.get(resource_location, headers: {}, open_timeout: nil, timeout: nil)
            end

            if attempts == max_attempts
              raise RestfulResource::MaximumAttemptsReached
            end
          end
          response = new_response
        end
      end
    end

    def self.wait(seconds)
      Kernel.sleep(seconds)
    end
  end
end
