module RestfulResource
  class Railtie < Rails::Railtie
    initializer "restful_resource.deprecator" do |app|
      app.deprecators[:restful_resource] = Base::Deprecator
    end
  end
end
