require 'spec_helper'
require 'zipkin-tracer/zipkin_null_sender'
require 'zipkin-tracer/zipkin_sqs_sender'
require 'lib/middleware_shared_examples'

describe ZipkinTracer::FaradayHandler do
  # allow stubbing of on_complete and response env
  class ResponseObject
    attr_reader :env

    def initialize(env, response_env)
      @env = env
      @response_env = response_env
    end

    def on_complete
      yield @response_env
      self
    end
  end

  let(:response_env) { { status: 404 } }
  let(:wrapped_app) { lambda { |env| ResponseObject.new(env, response_env) } }

  # returns the request headers
  def process(body, url, headers = {})
    env = {
      method: :post,
      url: url,
      body: body,
      request_headers: {}, #Faraday::Utils::Headers.new(headers),
    }
    middleware.call(env).env[:request_headers]
  end

  context 'middleware configured (without service_name)' do
    let(:middleware) { described_class.new(wrapped_app) }
    let(:service_name) { 'service' }

    context 'request with string URL' do
      let(:url) { raw_url }

      include_examples 'makes requests with tracing'
      include_examples 'makes requests without tracing'
    end

    # in testing, Faraday v0.8.x passes a URI object rather than a string
    context 'request with pre-parsed URL' do
      let(:url) { URI.parse(raw_url) }

      include_examples 'makes requests with tracing'
      include_examples 'makes requests without tracing'
    end
  end

  context 'configured with service_name "foo"' do
    let(:middleware) { described_class.new(wrapped_app, 'foo') }
    let(:service_name) { 'foo' }

    # in testing, Faraday v0.8.x passes a URI object rather than a string
    context 'request with pre-parsed URL' do
      let(:url) { URI.parse(raw_url) }

      include_examples 'makes requests with tracing'
      include_examples 'makes requests without tracing'
    end
  end

  context 'configured from a config hash' do
    let(:service_name) { 'service_name_from_config' }
    let(:queue_name) { 'zipkin-sqs' }
    let(:config) do
      {
        service_name: service_name,
        sqs_queue_name: queue_name,
        sample_rate: 1
      }
    end
    let(:url) { 'https://service.example.com/some/path/here' }
    let!(:middleware) { described_class.new(wrapped_app, nil, config) }

    before do
      Aws.config[:sqs] = {
        stub_responses: {
          get_queue_url: {
            queue_url: "http://#{queue_name}.com"
          }
        }
      }
    end

    it "uses the service name and sender set in the configuration" do
      expect(middleware.service_name).to eq('service_name_from_config')
      expect(middleware.tracer).to be_instance_of(Trace::ZipkinSqsSender)
      expect(middleware.tracer).to receive(:flush!)

      process('', url)
    end
  end
end
