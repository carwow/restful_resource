require_relative '../spec_helper'

RSpec.describe RestfulResource::RailsValidations do
  before do
    @mock_http = double('mock_http')
    Dealer.configure(base_url: 'http://api.carwow.co.uk/')
    allow(Dealer).to receive(:http).and_return(@mock_http)
  end

  describe '#patch without errors' do
    before do
      data = { name: 'Barak' }
      expected_response = RestfulResource::Response.new(body: { name: 'Barak' }.to_json)
      expect_patch('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.patch(1, data: data)
    end

    it 'returns object' do
      expect(@object.name).to eq 'Barak'
    end

    it 'returns valid object' do
      expect(@object).to be_valid
    end
  end

  describe '#patch with errors' do
    before do
      data = { name: 'Leonardo' }
      @error = 'Cannot use Ninja Turtles names'
      expected_response = RestfulResource::Response.new(body: { errors: [@error] }.to_json)
      expect_patch_with_unprocessable_entity('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.patch(1, data: data)
    end

    it 'has an error' do
      expect(@object.errors.count).to eq 1
    end

    it 'has correct error' do
      expect(@object.errors.first).to eq @error
    end

    it 'returns properly built object' do
      expect(@object.name).to eq 'Leonardo'
    end

    it 'returns not valid object' do
      expect(@object).not_to be_valid
    end

    it 'handles errors returned as root object' do
      data = { name: 'Michelangelo' }
      expected_response = RestfulResource::Response.new(body: @error.to_json)
      expect_patch_with_unprocessable_entity('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.patch(1, data: data)
      expect(@object).not_to be_valid
      expect(@object.errors).to eq @error
    end

    it 'returns the resource id as part of the response' do
      data = { name: 'Michelangelo' }
      expected_response = RestfulResource::Response.new(body: @error.to_json)
      expect_patch_with_unprocessable_entity('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.patch(1, data: data)
      expect(@object).not_to be_valid
      expect(@object.id).to be(1)
    end
  end

  describe '#put without errors' do
    before do
      data = { name: 'Barak' }
      expected_response = RestfulResource::Response.new(body: { name: 'Barak' }.to_json)
      expect_put('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.put(1, data: data)
    end

    it 'returns object' do
      expect(@object.name).to eq 'Barak'
    end

    it 'returns valid object' do
      expect(@object).to be_valid
    end
  end

  describe '#put with errors' do
    before do
      data = { name: 'Leonardo' }
      @error = 'Cannot use Ninja Turtles names'
      expected_response = RestfulResource::Response.new(body: { errors: [@error] }.to_json)
      expect_put_with_unprocessable_entity('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.put(1, data: data)
    end

    it 'has an error' do
      expect(@object.errors.count).to eq 1
    end

    it 'has correct error' do
      expect(@object.errors.first).to eq @error
    end

    it 'returns properly built object' do
      expect(@object.name).to eq 'Leonardo'
    end

    it 'returns not valid object' do
      expect(@object).not_to be_valid
    end

    it 'handles errors returned as root object' do
      data = { name: 'Michelangelo' }
      expected_response = RestfulResource::Response.new(body: @error.to_json)
      expect_put_with_unprocessable_entity('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.put(1, data: data)
      expect(@object).not_to be_valid
      expect(@object.errors).to eq @error
    end

    it 'returns the resource id as part of the response' do
      data = { name: 'Michelangelo' }
      expected_response = RestfulResource::Response.new(body: @error.to_json)
      expect_put_with_unprocessable_entity('http://api.carwow.co.uk/dealers/1', expected_response, data: data)

      @object = Dealer.put(1, data: data)
      expect(@object).not_to be_valid
      expect(@object.id).to be(1)
    end
  end

  describe '#post without errors' do
    before do
      data = { name: 'Barak' }
      expected_response = RestfulResource::Response.new(body: { name: 'Barak' }.to_json)
      expect_post('http://api.carwow.co.uk/dealers', expected_response, data: data)

      @object = Dealer.post(data: data)
    end

    it 'returns object' do
      expect(@object.name).to eq 'Barak'
    end

    it 'returns valid object' do
      expect(@object).to be_valid
    end
  end

  describe '#post with errors' do
    before do
      data = { name: 'Leonardo' }
      @error = 'Cannot use Ninja Turtles names'
      expected_response = RestfulResource::Response.new(body: { errors: [@error] }.to_json)
      expect_post_with_unprocessable_entity('http://api.carwow.co.uk/dealers', expected_response, data: data)

      @object = Dealer.post(data: data)
    end

    it 'has an error' do
      expect(@object.errors.count).to eq 1
    end

    it 'has correct error' do
      expect(@object.errors.first).to eq @error
    end

    it 'returns properly built object' do
      expect(@object.name).to eq 'Leonardo'
    end

    it 'returns not valid object' do
      expect(@object).not_to be_valid
    end

    it 'handles errors returned as root object' do
      data = { name: 'Michelangelo' }
      expected_response = RestfulResource::Response.new(body: @error.to_json)
      expect_post_with_unprocessable_entity('http://api.carwow.co.uk/dealers', expected_response, data: data)

      @object = Dealer.post(data: data)
      expect(@object).not_to be_valid
      expect(@object.errors).to eq @error
    end
  end

  describe '#get without errors' do
    before do
      expected_response = RestfulResource::Response.new(body: { name: 'Barak' }.to_json)
      expect_get('http://api.carwow.co.uk/dealers', expected_response)

      @object = Dealer.get
    end

    it 'returns object' do
      expect(@object.name).to eq 'Barak'
    end

    it 'returns valid object' do
      expect(@object).to be_valid
    end
  end

  describe '#get with errors' do
    before do
      @error = 'Missing parameter'
      expected_response = RestfulResource::Response.new(body: { errors: [@error] }.to_json)
      expect_get_with_unprocessable_entity('http://api.carwow.co.uk/dealers', expected_response)

      @object = Dealer.get
    end

    it 'has an error' do
      expect(@object.errors.count).to eq 1
    end

    it 'has correct error' do
      expect(@object.errors.first).to eq @error
    end

    it 'returns not valid object' do
      expect(@object).not_to be_valid
    end

    it 'handles errors returned as root object' do
      expected_response = RestfulResource::Response.new(body: @error.to_json)
      expect_get_with_unprocessable_entity('http://api.carwow.co.uk/dealers', expected_response)

      @object = Dealer.get
      expect(@object).not_to be_valid
      expect(@object.errors).to eq @error
    end
  end

  describe '#delete' do
    subject { Dealer.delete(123) }

    context 'without errors' do
      before do
        expected_response = RestfulResource::Response.new(body: { name: 'Barak' }.to_json)
        expect_delete('http://api.carwow.co.uk/dealers/123', expected_response)
      end

      it 'returns object' do
        expect(subject.name).to eq 'Barak'
      end

      it 'returns valid object' do
        expect(subject).to be_valid
      end
    end

    context 'with errors' do
      let(:errors) { { errors: ['Cannot use Ninja Turtles names'] } }

      before do
        expected_response = RestfulResource::Response.new(body: errors.to_json)
        expect_delete_with_unprocessable_entity('http://api.carwow.co.uk/dealers/123', expected_response)
      end

      it 'has an error' do
        expect(subject.errors.count).to eq 1
      end

      it 'has correct error' do
        expect(subject.errors.first).to eq 'Cannot use Ninja Turtles names'
      end

      it 'returns not valid object' do
        expect(subject).not_to be_valid
      end

      context 'when there is a single error' do
        let(:errors) { 'Cannot use Ninja Turtles names' }

        it 'handles errors returned as root object' do
          expect(subject).not_to be_valid
          expect(subject.errors).to eq errors
        end
      end
    end
  end
end
