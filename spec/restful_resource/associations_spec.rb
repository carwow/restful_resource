require_relative '../spec_helper'

describe RestfulResource::Associations do
  describe "#has_many" do
    before :each do
      @parent = ComplicatedModule::Parent.new({
        name: 'John Doe',
        other_things: [{stuff: 'aaa'}, {stuff: 'bbb'}],
        children:
          [
            {first_name: 'David', second_name: 'Doe'},
            {first_name: 'Mary', second_name: 'Doe'}
          ]
      })
    end

    it "should add a method to access nested resources" do
      expect(@parent.children.first.first_name).to eq 'David'
      expect(@parent.children.last.first_name).to eq 'Mary'
      expect(@parent.children.first.to_json).to eq({first_name: 'David', second_name: 'Doe'}.to_json)
    end

    it "should pick the right class for the instantiation of children" do
      expect(@parent.children.first.full_name).to eq 'David Doe'
    end

    it "should use open object when can't infer class name of association" do
      expect(@parent.other_things.first.stuff).to eq 'aaa'
    end

    it "should return nil for missing associations" do
      expect(@parent.missing).to be_nil
    end
  end

  describe "#has_one" do
    before :each do
      @child = ComplicatedModule::Child.new({
        first_name: 'David', second_name: 'Smith',
        parent: {name: 'John Smith'}
      })
    end

    it "should add a method to access nested resource" do
      expect(@child.parent.name).to eq 'John Smith'
      expect(@child.parent.to_json).to eq({name: 'John Smith'}.to_json)
    end

    it "should pick the right class for the instantiation of children" do
      expect(@child.parent.is_parent?).to be_truthy
    end
  end
end
