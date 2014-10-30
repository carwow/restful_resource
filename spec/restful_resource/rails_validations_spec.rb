require_relative '../spec_helper'

describe RestfulResource::RailsValidations do
  before :each do
    @mock_http = double("mock_http")
    RestfulResource::Base.configure(base_url: "http://api.carwow.co.uk/")
    allow(RestfulResource::Base).to receive(:http).and_return(@mock_http)
  end

  context "#put without errors" do
    before :each do
      data = {name: 'Barak'}
      expected_response = RestfulResource::Response.new(body: {name: 'Barak'}.to_json)
      expect_put("http://api.carwow.co.uk/dealers/1", expected_response, data: data)

      @object = Dealer.put(1, data: data)
    end

    it 'should return object' do
      expect(@object.name).to eq 'Barak'
    end

    it 'should return valid object' do
      expect(@object.valid?).to be_truthy
    end
  end

  context "#put with errors" do
    before :each do
      data = {name: 'Leonardo'}
      @error = 'Cannot use Ninja Turtles names'
      expected_response = RestfulResource::Response.new(body: {errors: [@error]}.to_json)
      expect_put_with_unprocessable_entity("http://api.carwow.co.uk/dealers/1", expected_response, data: data)

      @object = Dealer.put(1, data: data)
    end

    it "should have an error" do
      expect(@object.errors.count).to eq 1
    end

    it 'should have correct error' do
      expect(@object.errors.first).to eq @error
    end

    it 'should return properly built object' do
      expect(@object.name).to eq 'Leonardo'
    end

    it 'should return not valid object' do
      expect(@object.valid?).to be_falsey
    end
  end
end