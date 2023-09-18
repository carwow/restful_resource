require_relative '../spec_helper'

RSpec.describe RestfulResource::Base do
  before do
    @mock_http = double('mock_http')
    allow(Make).to receive(:http).and_return(@mock_http)
    Make.configure(base_url: 'http://api.carwow.co.uk/')
    allow(Model).to receive(:http).and_return(@mock_http)
    Model.configure(base_url: 'http://api.carwow.co.uk/')
  end

  it 'acts as an openobject' do
    object = described_class.new(name: 'David', surname: 'Santoro')

    expect(object.name).to eq 'David'
    expect(object.surname).to eq 'Santoro'
    expect { object.age }.to raise_error(NoMethodError)
  end

  describe '#parse_json' do
    it 'does not fail on empty string' do
      expect { described_class.send(:parse_json, ' ') }.not_to raise_error
    end
  end

  describe '#find' do
    it 'returns an object instance for the correct id' do
      expected_response = RestfulResource::Response.new(body: { id: 12 }.to_json)
      expect_get('http://api.carwow.co.uk/makes/12', expected_response)

      object = Make.find(12)

      expect(object).not_to be_nil
      expect(object.id).to be 12
    end

    it 'returns an object instance for nested routes' do
      expected_response = RestfulResource::Response.new(body: { name: 'Golf', price: 15_000 }.to_json)
      expect_get('http://api.carwow.co.uk/groups/15/makes/Volkswagen/models/Golf', expected_response)

      object = Model.find('Golf', make_slug: 'Volkswagen', group_id: 15)

      expect(object).not_to be_nil
      expect(object.name).to eq 'Golf'
      expect(object.price).to eq 15_000
    end

    it 'encodes parameters correctly in the url' do
      expected_response = RestfulResource::Response.new(body: { name: 'Golf', price: 15_000 }.to_json)
      expect_get('http://api.carwow.co.uk/groups/xxx+yyy%3Fl%3D7/makes/Land+Rover%3Fx%3D0.123/models/Golf+Cabriolet%3Ftest', expected_response)

      object = Model.find('Golf Cabriolet?test', make_slug: 'Land Rover?x=0.123', group_id: 'xxx yyy?l=7')
    end

    it 'accepts custom headers' do
      expect_get('http://api.carwow.co.uk/makes/12',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Make.find(12, headers: { cache_control: 'no-cache' })
    end

    it 'accepts no_cache option' do
      expect_get('http://api.carwow.co.uk/makes/12',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Make.find(12, no_cache: true)
    end
  end

  describe '#where' do
    it 'returns an array of objects' do
      expected_response = RestfulResource::Response.new(body: [{ name: 'Golf', price: 15_000 }, { name: 'Polo', price: 11_000 }].to_json)
      expect_get('http://api.carwow.co.uk/groups/15/makes/Volkswagen/models?on_sale=true', expected_response)
      object = Model.where(make_slug: 'Volkswagen', on_sale: true, group_id: 15)

      expect(object).not_to be_nil
      expect(object.length).to eq 2
      expect(object.first.name).to eq 'Golf'
      expect(object.first.price).to eq 15_000
    end

    it 'provides a paginated result if response contains rest pagination headers' do
      expected_response = response_with_page_information
      expect_get('http://api.carwow.co.uk/groups/15/makes/Volkswagen/models', expected_response)

      models = Model.where(group_id: 15, make_slug: 'Volkswagen')

      expect(models.first.name).to eq 'Golf'
      expect(models.last.name).to eq 'Polo'
      expect(models.previous_page).to be_nil
      expect(models.next_page).to eq 2
    end

    it 'accepts custom headers' do
      expect_get('http://api.carwow.co.uk/groups/15/makes/Volkswagen/models?on_sale=true',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Model.where(make_slug: 'Volkswagen', on_sale: true, group_id: 15, headers: { cache_control: 'no-cache' })
    end

    it 'accepts no_cache option' do
      expect_get('http://api.carwow.co.uk/groups/15/makes/Volkswagen/models?on_sale=true',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Model.where(make_slug: 'Volkswagen', on_sale: true, group_id: 15, no_cache: true)
    end
  end

  describe '#all' do
    it 'returns all items' do
      expected_response = RestfulResource::Response.new(body: [{ name: 'Volkswagen' }, { name: 'Audi' }].to_json)
      expect_get('http://api.carwow.co.uk/makes', expected_response)
      makes = Make.all

      expect(makes).not_to be_nil
      expect(makes.length).to eq 2
      expect(makes.first.name).to eq 'Volkswagen'
    end

    it 'accepts custom headers' do
      expect_get('http://api.carwow.co.uk/makes',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Make.all(headers: { cache_control: 'no-cache' })
    end

    it 'accepts no_cache option' do
      expect_get('http://api.carwow.co.uk/makes',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Make.all(no_cache: true)
    end
  end

  describe '#base_url' do
    before do
      @mock_http = double('mock_http')
      allow(TestA).to receive(:http).and_return(@mock_http)
      allow(TestB).to receive(:http).and_return(@mock_http)
    end

    it 'is different for each subclass of Base' do
      BaseA.configure(base_url: 'http://a.carwow.co.uk')
      BaseB.configure(base_url: 'http://b.carwow.co.uk')

      expect_get('http://a.carwow.co.uk/testa/1', RestfulResource::Response.new)
      expect_get('http://b.carwow.co.uk/testb/2', RestfulResource::Response.new)

      TestA.find(1)
      TestB.find(2)
    end
  end

  describe '#action' do
    it 'retrieves a resource using a custom action' do
      expect_get('http://api.carwow.co.uk/makes/15/lazy', RestfulResource::Response.new(body: { name: 'Volk.' }.to_json))

      make = Make.action(:lazy).find(15)

      expect(make.name).to eq 'Volk.'
    end

    it 'retrieves many resources using a custom action' do
      expect_get('http://api.carwow.co.uk/makes/available', RestfulResource::Response.new(body: [{ name: 'Audi' }, { name: 'Fiat' }].to_json))

      make = Make.action(:available).all

      expect(make.first.name).to eq 'Audi'
      expect(make.last.name).to eq 'Fiat'
    end
  end

  describe '#get' do
    it 'returns an open_object' do
      expected_response = RestfulResource::Response.new(body: { average_score: 4.3 }.to_json, status: 200)
      expect_get('http://api.carwow.co.uk/makes/average_score?make_slug%5B%5D=Volkswagen&make_slug%5B%5D=Audi', expected_response)

      object = Make.action(:average_score).get(make_slug: %w[Volkswagen Audi])

      expect(object.average_score).to eq 4.3
    end

    it 'accepts custom headers' do
      expect_get('http://api.carwow.co.uk/makes/average_score',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Make.action(:average_score).get(headers: { cache_control: 'no-cache' })
    end

    it 'accepts no_cache option' do
      expect_get('http://api.carwow.co.uk/makes/average_score',
        RestfulResource::Response.new,
        headers: { cache_control: 'no-cache' }
      )

      Make.action(:average_score).get(no_cache: true)
    end
  end

  describe '#patch' do
    it 'patchs no data with no params' do
      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_patch('http://api.carwow.co.uk/makes/1', expected_response)

      object = Make.patch(1)

      expect(object.name).to eq 'Audi'
    end

    it 'patchs no data with no params passed' do
      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_patch('http://api.carwow.co.uk/makes/1?make_slug=Volkswagen', expected_response)

      object = Make.patch(1, make_slug: 'Volkswagen')

      expect(object.name).to eq 'Audi'
    end

    it 'patchs data with params passed' do
      data = { make_slug: 'Audi' }

      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_patch('http://api.carwow.co.uk/makes/1', expected_response, data: data)

      object = Make.patch(1, data: { make_slug: 'Audi' })

      expect(object.name).to eq 'Audi'
    end

    it 'patchs data with params passed' do
      data = { make_slug: 'Audi' }

      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_patch('http://api.carwow.co.uk/makes/1?make_slug=Volkswagen', expected_response, data: data)

      object = Make.patch(1, data: data, make_slug: 'Volkswagen')

      expect(object.name).to eq 'Audi'
    end

    it 'accepts custom headers' do
      expect_patch('http://api.carwow.co.uk/makes/1',
        RestfulResource::Response.new,
        headers: { accept: 'application/json' }
      )

      Make.patch(1, data: {}, headers: { accept: 'application/json' })
    end
  end

  describe '#put' do
    it 'puts no data with no params' do
      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_put('http://api.carwow.co.uk/makes/1', expected_response)

      object = Make.put(1)

      expect(object.name).to eq 'Audi'
    end

    it 'puts no data with no params passed' do
      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_put('http://api.carwow.co.uk/makes/1?make_slug=Volkswagen', expected_response)

      object = Make.put(1, make_slug: 'Volkswagen')

      expect(object.name).to eq 'Audi'
    end

    it 'puts data with params passed' do
      data = { make_slug: 'Audi' }

      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_put('http://api.carwow.co.uk/makes/1', expected_response, data: data)

      object = Make.put(1, data: { make_slug: 'Audi' })

      expect(object.name).to eq 'Audi'
    end

    it 'puts data with params passed' do
      data = { make_slug: 'Audi' }

      expected_response = RestfulResource::Response.new(body: { name: 'Audi' }.to_json, status: 200)
      expect_put('http://api.carwow.co.uk/makes/1?make_slug=Volkswagen', expected_response, data: data)

      object = Make.put(1, data: data, make_slug: 'Volkswagen')

      expect(object.name).to eq 'Audi'
    end

    it 'accepts custom headers' do
      expect_put('http://api.carwow.co.uk/makes/1',
        RestfulResource::Response.new,
        headers: { accept: 'application/json' }
      )

      Make.put(1, data: {}, headers: { accept: 'application/json' })
    end
  end

  describe '#post' do
    it 'posts parameters to the collection url' do
      data = { slug: 'audi-make', name: 'Audi', num_of_cars: 3 }

      expected_response = RestfulResource::Response.new(body: data.to_json, status: 200)
      expect_post('http://api.carwow.co.uk/makes', expected_response, data: data)

      object = Make.post(data: data)

      expect(object.name).to eq 'Audi'
      expect(object.num_of_cars).to eq 3
    end

    it 'accepts custom headers' do
      expect_post('http://api.carwow.co.uk/makes',
        RestfulResource::Response.new,
        headers: { accept: 'application/json' }
      )

      Make.post(data: {}, headers: { accept: 'application/json' })
    end
  end

  describe '#delete' do
    it 'deletes to the member url' do
      expected_response = RestfulResource::Response.new(body: { deleted: true }.to_json, status: 200)
      expect_delete('http://api.carwow.co.uk/makes/1', expected_response)

      object = Make.delete(1)

      expect(object.deleted).to be_truthy
    end

    it 'accepts custom headers' do
      expect_delete('http://api.carwow.co.uk/makes/1',
        RestfulResource::Response.new,
        headers: { accept: 'application/json' }
      )

      Make.delete(1, headers: { accept: 'application/json' })
    end
  end

  describe '.as_json' do
    before do
      expected_response = RestfulResource::Response.new(body: [{ name: 'Audi', slug: 'Audi-Slug' }, { name: 'Fiat', slug: 'Fiat-Slug' }].to_json)
      expect_get('http://api.carwow.co.uk/makes', expected_response)

      @makes = Make.all
    end

    it 'does not return inner object table' do
      expect(@makes.first.as_json).to eq({ 'name' => 'Audi', 'slug' => 'Audi-Slug' })
    end

    it 'returns inner object table on selected fields' do
      expect(@makes.last.as_json(only: [:name])).to eq({ 'name' => 'Fiat' })
    end
  end

  describe '.member_url' do
    it 'requires a member ID' do
      expect { described_class.member_url('') }.to raise_error(RestfulResource::ResourceIdMissingError)
    end
  end

  describe '.configure' do
    let(:username) { double }
    let(:password) { double }
    let(:auth_token) { double }
    let(:logger) { double }
    let(:cache_store) { double }
    let(:instrumentation) { double }
    let(:timeout) { double }
    let(:open_timeout) { double }
    let(:faraday_config) { double }
    let(:faraday_options) { double }
    let(:default_headers) { double }

    it 'passes arguments to HttpClient' do
      client = Class.new(described_class)
      expect(RestfulResource::HttpClient).to receive(:new).with(
        username: username,
        password: password,
        auth_token: auth_token,
        logger: logger,
        cache_store: cache_store,
        instrumentation: instrumentation,
        timeout: timeout,
        open_timeout: open_timeout,
        faraday_config: faraday_config,
        faraday_options: faraday_options,
        default_headers: default_headers
      )

      client.configure(
        base_url: 'http://foo.bar',
        username: username,
        password: password,
        auth_token: auth_token,
        logger: logger,
        cache_store: cache_store,
        instrumentation: instrumentation,
        timeout: timeout,
        open_timeout: open_timeout,
        faraday_config: faraday_config,
        faraday_options: faraday_options,
        default_headers: default_headers
      )
    end
  end

  def response_with_page_information
    RestfulResource::Response.new(body: [{ id: 1, name: 'Golf' }, { id: 2, name: 'Polo' }].to_json,
                                  headers: { links: '<http://api.carwow.co.uk/makes/Volkswagen/models.json?page=6>;rel="last",<http://api.carwow.co.uk/makes/Volkswagen/models.json?page=2>;rel="next"' }
                                 )
  end
end
