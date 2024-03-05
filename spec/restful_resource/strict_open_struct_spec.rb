require_relative '../spec_helper'

RSpec.describe RestfulResource::StrictOpenStruct do
  let(:instance) { described_class.new(foo: 'bar') }

  describe '#dig' do
    it 'is deprecated' do
      expect { instance.dig(:foo) }.to output(
        /dig is deprecated and will be removed from restful_resource soon/
      ).to_stderr
    end
  end

  describe '#[]' do
    it 'is deprecated' do
      expect { instance[:foo] }.to output(
        /\[\] is deprecated and will be removed from restful_resource soon/
      ).to_stderr
    end
  end
end
