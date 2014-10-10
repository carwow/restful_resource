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
      expect(@mock_http).to receive(:get).with("http://api.carwow.co.uk/makes/12").and_return({id: 12}.to_json)

      object = Make.find(12)

      expect(object).not_to be_nil
      expect(object.id).to be 12
    end

    it "should return an object instance for nested routes" do
      expect(@mock_http).to receive(:get).with("http://api.carwow.co.uk/groups/15/makes/Volkswagen/models/Golf").and_return({name: 'Golf', price: 15000}.to_json)

      object = Model.find('Golf', make_slug: 'Volkswagen', group_id: 15)

      expect(object).not_to be_nil
      expect(object.name).to eq 'Golf'
      expect(object.price).to eq 15000
    end
  end
end


class Make < RestfulResource::Base
  self.resource_url = "makes"
end

class Model < RestfulResource::Base
  self.resource_url = "groups/:group_id/makes/:make_slug/models"
end
