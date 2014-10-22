module RestfulResource
  class Authorization
    def self.http_authorization(user, password)
      'Basic ' + Base64.encode64("#{user}:#{password}").chomp
    end
  end
end
