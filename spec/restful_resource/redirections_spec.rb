require_relative '../spec_helper'

describe RestfulResource::Redirections do
  before :each do
    @mock_http = double("mock_http")
    allow(RestfulResource::Base).to receive(:http).and_return(@mock_http)
    RestfulResource::Base.configure(base_url: 'http://api.carwow.co.uk/')
  end

  describe "#post" do
    let(:data) { {data: 123} }

    subject { ModelWithRedirections.post(data: data) }

    context 'with a 200 response' do
      it 'should behave as usual' do
        expected_response = RestfulResource::Response.new(body: {test_data: 42}.to_json)
        expect_post("http://api.carwow.co.uk/model_with_redirections", expected_response, data: data)

        expect(subject.test_data).to eq 42
      end
    end

    context 'with a redirect to resource location' do
      let(:redirect_target) { 'http://api.carwow.co.uk/model_with_redirections/123' }

      before(:each) do
        allow(RestfulResource::Redirections).to receive(:wait)
        expected_redirect_response = RestfulResource::Response.new(body: 'You are being redirected', status: 303, headers: { location: redirect_target})
        expect_post("http://api.carwow.co.uk/model_with_redirections", expected_redirect_response, data: data)
      end

      it 'should get the resource from the new location' do
        expected_get_response = RestfulResource::Response.new(body: {test_data: 42}.to_json, status: 200)
        expect_get(redirect_target, expected_get_response)

        expect(subject.test_data).to eq 42
      end

      it 'should wait 0.5 seconds after first redirect' do
        expected_get_response = RestfulResource::Response.new(body: {test_data: 42}.to_json, status: 200)

        expect(RestfulResource::Redirections).to receive(:wait).with(0.5).ordered
        expect_get(redirect_target, expected_get_response).ordered

        expect(subject.test_data).to eq 42
      end

      it 'should wait 0.5 between retries' do
        resource_not_ready_get_response = RestfulResource::Response.new(body: 'pending', status: 202)
        resource_ready_get_response = RestfulResource::Response.new(body: {test_data: 42}.to_json, status: 200)

        expect(RestfulResource::Redirections).to receive(:wait).with(0.5).ordered
        expect_get(redirect_target, resource_not_ready_get_response).ordered
        expect(RestfulResource::Redirections).to receive(:wait).with(0.5).ordered
        expect_get(redirect_target, resource_ready_get_response).ordered

        expect(subject.test_data).to eq 42
      end

      it 'should retry 10 times by default' do
        resource_not_ready_get_response = RestfulResource::Response.new(body: 'pending', status: 202)
        resource_ready_get_response = RestfulResource::Response.new(body: {test_data: 42}.to_json, status: 200)

        9.times do
          expect(RestfulResource::Redirections).to receive(:wait).with(0.5).ordered
          expect_get(redirect_target, resource_not_ready_get_response).ordered
        end
        expect(RestfulResource::Redirections).to receive(:wait).with(0.5).ordered
        expect_get(redirect_target, resource_ready_get_response).ordered

        expect(subject.test_data).to eq 42
      end

      it 'raise after max_retries value is reached' do
        resource_not_ready_get_response = RestfulResource::Response.new(body: 'pending', status: 202)
        resource_ready_get_response = RestfulResource::Response.new(body: {test_data: 42}.to_json, status: 200)

        11.times do
          expect(RestfulResource::Redirections).to receive(:wait).with(0.5).ordered
          expect_get(redirect_target, resource_not_ready_get_response).ordered
        end

        expect{subject}.to raise_error(RestfulResource::MaximumAttemptsReached)
      end
    end
  end
end
