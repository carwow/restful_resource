require_relative '../spec_helper'

RSpec.describe RestfulResource::StrictOpenStruct do
  let(:instance) { described_class.new(foo: 'bar') }

  describe '#dig' do
    it 'is not defined' do
      expect { instance.dig(:foo) }.to raise_error(NoMethodError)
    end
  end

  describe '#[]' do
    it 'is not defined' do
      expect { instance[:foo] }.to raise_error(NoMethodError)
    end
  end
end
