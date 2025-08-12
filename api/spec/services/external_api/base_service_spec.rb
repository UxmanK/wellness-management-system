require 'rails_helper'

RSpec.describe ExternalApi::BaseService do
  subject(:service) { described_class.new }

  let(:options_double) do
    instance_double(
      Faraday::RequestOptions,
      timeout: nil,
      open_timeout: nil
    )
  end

  let(:faraday_double) do
    instance_double(Faraday::Connection,
      request: nil,
      adapter: nil,
      options: options_double
    )
  end

  let(:request_double) do
    instance_double(Faraday::Request,
      url: nil,
      headers: {},
      params: {},
      body: nil
    )
  end

  let(:response_double) do
    instance_double(Faraday::Response,
      status: 200,
      body: '{"result": "success"}'
    )
  end

  let(:logger_double) do
    instance_double(Logger, info: nil, warn: nil)
  end

  before do
    allow(Rails).to receive(:logger).and_return(logger_double)
  end

  describe '.configure' do
    it 'allows setting configuration options' do
      described_class.configure do |config|
        config.base_url = 'https://custom.example.com'
        config.api_key = 'custom_key'
        config.timeout = 10
        config.retry_attempts = 5
      end

      expect(described_class.base_url).to eq('https://custom.example.com')
      expect(described_class.api_key).to eq('custom_key')
      expect(described_class.timeout).to eq(10)
      expect(described_class.retry_attempts).to eq(5)
    end
  end



  describe '#handle_response' do
    it 'returns parsed JSON for success' do
      expect(service.send(:handle_response, response_double)).to eq({ 'result' => 'success' })
    end

    it 'raises for 401' do
      resp = instance_double(Faraday::Response, status: 401, body: 'Unauthorized')
      expect {
        service.send(:handle_response, resp)
      }.to raise_error(ExternalApi::ExternalApiError, /Authentication failed/)
    end

    it 'raises for 500' do
      resp = instance_double(Faraday::Response, status: 500, body: 'Server error')
      expect {
        service.send(:handle_response, resp)
      }.to raise_error(ExternalApi::ExternalApiError, /Server error/)
    end
  end
end
