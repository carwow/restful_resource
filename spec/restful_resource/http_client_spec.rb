require_relative '../spec_helper'

describe RestfulResource::HttpClient do
  describe 'Basic HTTP' do
    before :each do
      @http_client = RestfulResource::HttpClient.new
    end

    describe '#get' do
      it 'successfully executes get' do
        response = @http_client.get('http://httpbin.org/get')
        expect(response.status).to eq 200
      end

      context 'when there is an error' do
        before do
          allow(RestClient).to receive(:get) { raise error }
        end

        let(:error) { StandardError }

        it 'raises the error' do
          expect {
            @http_client.get('http://httpbin.org/get')
          }.to raise_error(error)
        end
      end

      context 'when there is an UnknownError' do
        before do
          allow(RestClient).to receive(:get) { raise error }
        end

        let(:error) { NoMethodError.new("undefined method `each` for nil:NilClass") }

        it 'raises the error' do
          expect {
            @http_client.get('http://httpbin.org/get')
          }.to raise_error(
            RestfulResource::HttpClient::UnknownError,
            "http://httpbin.org/get: failed with undefined method `each` for nil:NilClass"
          )
        end
      end
    end

    it 'should execute put' do
      response = @http_client.put('http://httpbin.org/put', data: { name: 'Alfred' })
      expect(response.status).to eq 200
    end

    it 'should execute post' do
      response = @http_client.post('http://httpbin.org/post', data: { name: 'Alfred' })
      expect(response.body).to include "name\": \"Alfred"
      expect(response.status).to eq 200
    end

    it 'should execute delete' do
      response = @http_client.delete('http://httpbin.org/delete')
      expect(response.status).to eq 200
    end

    it 'put should raise error 422' do
      expect { @http_client.put('http://httpbin.org/status/422', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end

    it 'post should raise error 422' do
      expect { @http_client.post('http://httpbin.org/status/422', data: { name: 'Mad cow' }) }.to raise_error(RestfulResource::HttpClient::UnprocessableEntity)
    end
  end

  describe 'Authentication' do
    before :each do
      auth = RestfulResource::Authorization.http_authorization('user', 'passwd')
      @http_client = RestfulResource::HttpClient.new(authorization: auth)
    end

    it 'should execute authenticated get' do
      response = @http_client.get('http://httpbin.org/basic-auth/user/passwd')
      expect(response.status).to eq 200
    end
  end
end
