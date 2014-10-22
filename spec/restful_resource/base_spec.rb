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
      expect_get("http://api.carwow.co.uk/groups/15/makes/Volkswagen/models?on_sale=true", expected_response)
      object = Model.where(make_slug: 'Volkswagen', on_sale: true, group_id: 15)

      expect(object).not_to be_nil
      expect(object.length).to eq 2
      expect(object.first.name).to eq 'Golf'
      expect(object.first.price).to eq 15000
    end

    it "should provide a paginated result if response contains rest pagination headers" do
      expected_response = response_with_page_information()
      expect_get("http://api.carwow.co.uk/groups/15/makes/Volkswagen/models", expected_response)

      models = Model.where(group_id: 15, make_slug: 'Volkswagen')

      expect(models.first.name).to eq 'Golf'
      expect(models.last.name).to eq 'Polo'
      expect(models.previous_page).to be_nil
      expect(models.next_page).to eq 2
    end
  end

  describe "#all" do
    it "should return all items" do
      expected_response = RestfulResource::Response.new(body: [{name: 'Volkswagen'}, {name: 'Audi'}].to_json)
      expect_get("http://api.carwow.co.uk/makes", expected_response)
      makes = Make.all

      expect(makes).not_to be_nil
      expect(makes.length).to eq 2
      expect(makes.first.name).to eq 'Volkswagen'
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

  describe "#action" do
    it "should retrieve a resource using a custom action" do
      expect_get('http://api.carwow.co.uk/makes/15/lazy', RestfulResource::Response.new(body: {name: 'Volk.'}.to_json))

      make = Make.action(:lazy).find(15)

      expect(make.name).to eq 'Volk.'
    end

    it 'should retrieve many resources using a custom action' do
      expect_get('http://api.carwow.co.uk/makes/available', RestfulResource::Response.new(body: [{name: 'Audi'}, {name: 'Fiat'}].to_json))

      make = Make.action(:available).all

      expect(make.first.name).to eq 'Audi'
      expect(make.last.name).to eq 'Fiat'
    end
  end

  describe "#get" do 
    it "should return an open_object" do
      expected_response = RestfulResource::Response.new(body: {average_score: 4.3}.to_json)
      expect_get('http://api.carwow.co.uk/makes/average_score?make_slug%5B%5D=Volkswagen&make_slug%5B%5D=Audi', expected_response)

      object = Make.action(:average_score).get(make_slug: ['Volkswagen', 'Audi'])

      expect(object.average_score).to eq 4.3
      expect(object.class).to eq RestfulResource::OpenObject
    end
  end

  describe ".as_json" do
    before :each do
      expected_response = RestfulResource::Response.new(body: [{name: 'Audi', slug: 'Audi-Slug'}, {name: 'Fiat', slug: 'Fiat-Slug'}].to_json)
      expect_get('http://api.carwow.co.uk/makes', expected_response)

      @makes = Make.all
    end

    it 'should not return inner object table' do
      expect(@makes.first.as_json).to eq ({'name' => 'Audi', 'slug' => 'Audi-Slug'})
    end

    it 'should return inner object table on selected fields' do
      expect(@makes.last.as_json(only: [:name])).to eq ({'name' => 'Fiat'})
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

