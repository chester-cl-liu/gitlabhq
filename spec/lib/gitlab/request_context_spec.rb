require 'spec_helper'

describe Gitlab::RequestContext, lib: true do
  describe '#client_ip' do
    subject { Gitlab::RequestContext.client_ip }
    let(:app) { -> (env) {} }
    let(:env) { Hash.new }

    context 'when RequestStore::Middleware is used' do
      around(:each) do |example|
        RequestStore::Middleware.new(-> (env) { example.run }).call({})
      end

      context 'request' do
        let(:ip) { '192.168.1.11' }

        before do
          allow_any_instance_of(Rack::Request).to receive(:ip).and_return(ip)
          Gitlab::RequestContext.new(app).call(env)
        end

        it { is_expected.to eq(ip) }
      end

      context 'before RequestContext middleware run' do
        it { is_expected.to be_nil }
      end
    end
  end
end
