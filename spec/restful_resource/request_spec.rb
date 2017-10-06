require 'spec_helper'

RSpec.describe RestfulResource::Request do
  let(:method) { 'get' }
  let(:url) { 'https://www.carwow.co.uk/api/v2/models' }

  describe '.headers' do
    context 'given no headers' do
      subject { described_class.new(method, url).headers }

      its(['Accept']) { is_expected.to eq 'application/json' }
    end

    context 'given an explicit accept header' do
      subject { described_class.new(method, url, headers: { accept: 'application/xml' }).headers }

      its(['Accept']) { is_expected.to eq 'application/xml' }
    end

    context 'given symbolized header' do
      subject { described_class.new(method, url, headers: { authorization: 'Bearer: xyz' }).headers }

      its(['Authorization']) { is_expected.to eq 'Bearer: xyz' }
      its(['Accept']) { is_expected.to eq 'application/json' }
    end

    context 'given multi word symbolized header' do
      subject { described_class.new(method, url, headers: { cache_control: 'no-cache' }).headers }

      its(['Cache-Control']) { is_expected.to eq 'no-cache' }
      its(['Accept']) { is_expected.to eq 'application/json' }
    end

    context 'given string header' do
      subject { described_class.new(method, url, headers: { 'authorization' => 'Bearer: xyz' }).headers }

      its(['Authorization']) { is_expected.to eq 'Bearer: xyz' }
      its(['Accept']) { is_expected.to eq 'application/json' }
    end

    context 'given multi word string header' do
      subject { described_class.new(method, url, headers: { 'cache control' => 'no-cache' }).headers }

      its(['Cache-Control']) { is_expected.to eq 'no-cache' }
      its(['Accept']) { is_expected.to eq 'application/json' }
    end
  end
end
