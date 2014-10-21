require_relative '../spec_helper'

describe RestfulResource::Base do
  before :each do
    @mock_http = double("mock_http")
    RestfulResource::Base.http = @mock_http
    RestfulResource::Base.base_url = "http://api.carwow.co.uk/"
  end

  it "should act as an openobject" do
    object = RestfulResource::Base.new(name: 'David', surname: 'Santoro')

    expect(object.name).to eq 'David'
    expect(object.surname).to eq 'Santoro'
    expect { object.age }.to raise_error(NoMethodError)
  end

  describe "#find" do
    it "should return an object instance for the correct id" do
      expected_response = RestfulResource::Response.new(body: {id: 12}.to_json)
      expect_get("http://api.carwow.co.uk/makes/12", expected_response)

      object = Make.find(12)

      expect(object).not_to be_nil
      expect(object.id).to be 12
    end

    it "should return an object instance for nested routes" do
      expected_response = RestfulResource::Response.new(body: {name: 'Golf', price: 15000}.to_json)
      expect_get("http://api.carwow.co.uk/groups/15/makes/Volkswagen/models/Golf", expected_response)

      object = Model.find('Golf', make_slug: 'Volkswagen', group_id: 15)

      expect(object).not_to be_nil
      expect(object.name).to eq 'Golf'
      expect(object.price).to eq 15000
    end
  end

  describe "#where" do
    it "should return an array of objects" do
      expected_response = RestfulResource::Response.new(body: [{name: 'Golf', price: 15000}, {name: 'Polo', price: 11000}].to_json)
      expect_get("http://api.carwow.co.uk/groups/15/makes/Volkswagen/models/?on_sale=true", expected_response)
      object = Model.where(make_slug: 'Volkswagen', on_sale: true, group_id: 15)

      expect(object).not_to be_nil
      expect(object.length).to eq 2
      expect(object.first.name).to eq 'Golf'
      expect(object.first.price).to eq 15000
    end

    it "should provide a paginated result if response contains rest pagination headers" do
      expected_response = response_with_page_information()
      expect_get("http://api.carwow.co.uk/groups/15/makes/Volkswagen/models/", expected_response)

      models = Model.where(group_id: 15, make_slug: 'Volkswagen')

      expect(models.first.name).to eq 'Golf'
      expect(models.last.name).to eq 'Polo'
      expect(models.previous_page).to be_nil
      expect(models.next_page).to eq 2
    end
  end

  describe "#base_url" do
    it "should be different for each subclass of Base" do
      BaseA.base_url = "http://a.carwow.co.uk"
      BaseB.base_url = "http://b.carwow.co.uk"

      expect_get('http://a.carwow.co.uk/testa/1', RestfulResource::Response.new())
      expect_get('http://b.carwow.co.uk/testb/2', RestfulResource::Response.new())

      TestA.find(1)
      TestB.find(2)
    end
  end


  def expect_get(url, response)
    expect(@mock_http).to receive(:get).with(url).and_return(response)
  end

  def response_with_page_information
    RestfulResource::Response.new(body: [{ id: 1, name: 'Golf'}, { id: 2, name: 'Polo' }].to_json,
                                 headers: { links: '<http://api.carwow.co.uk/makes/Volkswagen/models.json?page=6>;rel="last",<http://api.carwow.co.uk/makes/Volkswagen/models.json?page=2>;rel="next"'})
  end
end

class Make < RestfulResource::Base
  self.resource_url = "makes"
end

class Model < RestfulResource::Base
  self.resource_url = "groups/:group_id/makes/:make_slug/models"
end

class BaseA < RestfulResource::Base
end

class BaseB < RestfulResource::Base
end

class TestA < BaseA
  self.resource_url = "testa"
end

class TestB < BaseB
  self.resource_url = "testb"
end
