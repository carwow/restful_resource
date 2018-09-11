class Make < RestfulResource::Base
  resource_path 'makes'
  has_many :models
end

class Model < RestfulResource::Base
  has_one :make
  resource_path 'groups/:group_id/makes/:make_slug/models'
end

class Dealer < RestfulResource::Base
  include RestfulResource::RailsValidations

  resource_path 'dealers'
end

class BaseA < RestfulResource::Base
end

class BaseB < RestfulResource::Base
end

class TestA < BaseA
  resource_path 'testa'
end

class TestB < BaseB
  resource_path 'testb'
end

class ModelWithRedirections < RestfulResource::Base
  include RestfulResource::Redirections

  resource_path 'model_with_redirections'
end

module ComplicatedModule
  class Parent < BaseA
    resource_path 'parent'
    has_many :children
    has_many :other_things
    has_many :missing

    def is_parent?
      true
    end
  end

  class Child < BaseA
    resource_path 'parents/:parent_id/children'
    has_one :parent

    def full_name
      "#{first_name} #{second_name}"
    end
  end
end
