require_relative '../spec_helper'

describe RestfulResource::OpenObject do
  it 'acts as an openstruct' do
    object = described_class.new(name: 'David', surname: 'Santoro')

    expect(object.name).to eq 'David'
    expect(object.surname).to eq 'Santoro'
  end

  it "raises an error when accessing a field that doesn't exist" do
    object = described_class.new(name: 'David', surname: 'Santoro')

    expect { object.age }.to raise_error(NoMethodError)
  end

  it 'implements equality operators correctly' do
    a = described_class.new(name: 'Joe', age: 13)
    b = described_class.new(name: 'Joe', age: 13)
    c = described_class.new(name: 'Mike', age: 13)

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
