require_relative '../spec_helper'

describe RestfulResource::Associations do
  describe "#has_many" do
    it "should add a method to access nested resource" do
      make = Make.new({
        name: 'Volkswagen',
        models:
          [
            {name: 'Golf', rrp: 1000},
            {name: 'Passat', rrp: 3000}
          ]
      })

      expect(make.models.first.name).to eq 'Golf'
      expect(make.models.last.name).to eq 'Passat'
      expect(make.models.first.rrp).to eq 1000
      expect(make.models.last.rrp).to eq 3000
      expect(make.models.first.to_json).to eq({name: 'Golf', rrp: 1000}.to_json)
    end
  end

  describe "#has_one" do
    it "should add a method to access nested resource" do
      model = Model.new({
        name: 'Golf',
        make: {name: 'Volkswagen'}
      })

      expect(model.make.name).to eq 'Volkswagen'
      expect(model.make.to_json).to eq({name: 'Volkswagen'}.to_json)
    end
  end
end
