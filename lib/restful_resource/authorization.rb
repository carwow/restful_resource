module RestfulResource
  class Authorization
    def self.http_authorization(user, password)
      'Basic ' + Base64.strict_encode64("#{user}:#{password}")
    end
  end
end
