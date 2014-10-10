require_relative '../spec_helper'

describe RestfulResource::OpenObject do
  it "should act as an openstruct" do
    object = RestfulResource::OpenObject.new(name: 'David', surname: 'Santoro')

    expect(object.name).to eq 'David'
    expect(object.surname).to eq 'Santoro'
  end

  it "should raise an error when accessing a field that doesn't exist" do
    object = RestfulResource::OpenObject.new({name: 'David', surname: 'Santoro'})

    expect { object.age }.to raise_error(NoMethodError)
  end
end
