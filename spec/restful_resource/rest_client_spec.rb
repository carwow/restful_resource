require_relative '../spec_helper'

describe RestfulResource::Base do
  context "#get" do
    it "should throw an exception with wrong url" do
      expect{RestClient.get("http://www.example.com/djksafjadl", params: {})}.to raise_error
    end

    it "should throw an exception with wrong url" do
      r = RestClient::Resource.new("http://www.example.com/djksafjadl")
      expect{r.get}.to raise_error
    end
  end

end
