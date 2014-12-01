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

module ComplicatedModule
  class Parent < RestfulResource::Base
    resource_path "parent"
    has_many :children

    def is_parent?
      true
    end
  end

  class Child < RestfulResource::Base
    resource_path 'parents/:parent_id/children'
    has_one :parent

    def full_name
      "#{self.first_name} #{self.second_name}"
    end
  end
end
