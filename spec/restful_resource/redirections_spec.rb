require_relative '../spec_helper'

RSpec.describe RestfulResource::Redirections do
  before do
    @mock_http = double('mock_http')
    allow(ModelWithRedirections).to receive(:http).and_return(@mock_http)
    ModelWithRedirections.configure(base_url: 'http://api.carwow.co.uk/')
  end

  describe '#post' do
    subject { ModelWithRedirections.post(data: data) }

    let(:data) { { data: 123 } }

    context 'with a 200 response' do
      it 'behaves as usual' do
        expected_response = RestfulResource::Response.new(body: { test_data: 42 }.to_json)
        expect_post('http://api.carwow.co.uk/model_with_redirections', expected_response, data: data)

        expect(subject.test_data).to eq 42
      end
    end

    context 'with a redirect to resource location' do
      let(:redirect_target) { 'http://api.carwow.co.uk/model_with_redirections/123' }

      before do
        allow(described_class).to receive(:wait)
        expected_redirect_response = RestfulResource::Response.new(body: 'You are being redirected', status: 303, headers: { location: redirect_target })
        expect_post('http://api.carwow.co.uk/model_with_redirections', expected_redirect_response, data: data)
      end

      it 'gets the resource from the new location' do
        expected_get_response = RestfulResource::Response.new(body: { test_data: 42 }.to_json, status: 200)
        expect_get(redirect_target, expected_get_response)

        expect(subject.test_data).to eq 42
      end

      it 'waits 1.0 seconds after first redirect' do
        expected_get_response = RestfulResource::Response.new(body: { test_data: 42 }.to_json, status: 200)

        expect(described_class).to receive(:wait).with(1.0).ordered
        expect_get(redirect_target, expected_get_response).ordered

        expect(subject.test_data).to eq 42
      end

      it 'waits 1.0 seconds between retries' do
        resource_not_ready_get_response = RestfulResource::Response.new(body: 'pending', status: 202)
        resource_ready_get_response = RestfulResource::Response.new(body: { test_data: 42 }.to_json, status: 200)

        expect(described_class).to receive(:wait).with(1.0).ordered
        expect_get(redirect_target, resource_not_ready_get_response).ordered
        expect(described_class).to receive(:wait).with(1.0).ordered
        expect_get(redirect_target, resource_ready_get_response).ordered

        expect(subject.test_data).to eq 42
      end

      it 'retries 10 times by default' do
        resource_not_ready_get_response = RestfulResource::Response.new(body: 'pending', status: 202)
        resource_ready_get_response = RestfulResource::Response.new(body: { test_data: 42 }.to_json, status: 200)

        9.times do
          expect(described_class).to receive(:wait).with(1.0).ordered
          expect_get(redirect_target, resource_not_ready_get_response).ordered
        end
        expect(described_class).to receive(:wait).with(1.0).ordered
        expect_get(redirect_target, resource_ready_get_response).ordered

        expect(subject.test_data).to eq 42
      end

      it 'raise after max_retries value is reached' do
        resource_not_ready_get_response = RestfulResource::Response.new(body: 'pending', status: 202)
        resource_ready_get_response = RestfulResource::Response.new(body: { test_data: 42 }.to_json, status: 200)

        11.times do
          expect(described_class).to receive(:wait).with(1.0).ordered
          expect_get(redirect_target, resource_not_ready_get_response).ordered
        end

        expect { subject }.to raise_error(RestfulResource::MaximumAttemptsReached)
      end
    end
  end
end
