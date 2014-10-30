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

  it "should implement equality operators correctly" do
    a = RestfulResource::OpenObject.new({name: 'Joe', age: 13})
    b = RestfulResource::OpenObject.new({name: 'Joe', age: 13})
    c = RestfulResource::OpenObject.new({name: 'Mike', age: 13})

    list = [a, b, c]

    expect(a == b).to eq true
    expect(a.eql?(b)).to eq true
    expect(a.equal?(b)).to eq false

    expect(a == c).to eq false
    expect(a.eql?(c)).to eq false
    expect(a.equal?(c)).to eq false
    expect(list.uniq.length).to eq 2
  end
end
