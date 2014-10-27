class Make < RestfulResource::Base
  resource_path "makes"
  has_many :models
end

class Model < RestfulResource::Base
  has_one :make
  resource_path "groups/:group_id/makes/:make_slug/models"
end

class Dealer < RestfulResource::Base
  include RestfulResource::RailsValidations

  resource_path "dealers"
end

class BaseA < RestfulResource::Base
end

class BaseB < RestfulResource::Base
end

class TestA < BaseA
  self.resource_path "testa"
end

class TestB < BaseB
  self.resource_path "testb"
end
