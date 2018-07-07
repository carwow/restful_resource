require_relative '../spec_helper'

describe RestfulResource::PromiseOpenObject do
  it "should act as an openstruct" do
    object = RestfulResource::PromiseOpenObject.new(name: 'David', surname: 'Santoro')

    expect(object.name).to eq 'David'
    expect(object.surname).to eq 'Santoro'
  end

  it "should raise an error when accessing a field that doesn't exist" do
    object = RestfulResource::PromiseOpenObject.new({name: 'David', surname: 'Santoro'})

    expect { object.age }.to raise_error(NoMethodError)
  end

  it "should implement equality operators correctly" do
    a = RestfulResource::PromiseOpenObject.new({name: 'Joe', age: 13})
    b = RestfulResource::PromiseOpenObject.new({name: 'Joe', age: 13})
    c = RestfulResource::PromiseOpenObject.new({name: 'Mike', age: 13})

    list = [a, b, c]

    expect(a == b).to eq true
    expect(a.eql?(b)).to eq true
    expect(a.equal?(b)).to eq false

    expect(a == c).to eq false
    expect(a.eql?(c)).to eq false
    expect(a.equal?(c)).to eq false
    expect(list.uniq.length).to eq 2
  end

  context 'when a block is passed in' do
    it 'executes the blocks in parallel' do
      start_time = Time.now
      a = RestfulResource::PromiseOpenObject.new { sleep 1; {value: :a} }
      b = RestfulResource::PromiseOpenObject.new { sleep 1; {value: :b} }

      expect(a.value).to eq(:a)
      expect(b.value).to eq(:b)

      expect((start_time - Time.now) < 2).to be_truthy
    end

    it 'implements equality correctly' do
      a = RestfulResource::PromiseOpenObject.new { { name: 'Joe', age: 13 } }
      b = RestfulResource::PromiseOpenObject.new { { name: 'Joe', age: 13 } }
      c = RestfulResource::PromiseOpenObject.new { { name: 'Mike', age: 13 } }

      expect(a == b).to eq true
      expect(a.eql?(b)).to eq true
      expect(a.equal?(b)).to eq false

      expect(a == c).to eq false
      expect(a.eql?(c)).to eq false
      expect(a.equal?(c)).to eq false

      list = [a, b, c]
      expect(list.uniq.length).to eq 2
    end

    context 'when the block raises an exception' do
      it 'can be rescued using #rescue' do
        object = RestfulResource::PromiseOpenObject.new { raise 'oops' }

        object.rescue do |exception|
          expect(exception.class).to eq(RuntimeError)
          expect(exception.message).to eq('oops')
        end

        expect(object.as_json).to eq({})
      end

      it 'raises the exception if a value is accessed' do
        object = RestfulResource::PromiseOpenObject.new { raise 'oops' }

        expect { object.value }.to raise_error 'oops'
      end
    end
  end
end
