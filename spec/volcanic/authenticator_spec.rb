# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator, :vcr do
  describe 'Config' do
    let(:config) { Volcanic::Authenticator.config }
    let(:app_token) { Volcanic::Authenticator::V1::AppToken }

    context 'When missing auth url' do
      before { Configuration.reset }
      it { expect { config.auth_url }.to raise_error Volcanic::Authenticator::V1::ConfigurationError }
    end

    context 'When missing application name' do
      it { expect(config.app_name).to be nil }
    end

    context 'When missing application secret' do
      it { expect(config.app_secret).to be nil }
    end

    context 'When invalid expiration token' do
      it { expect { config.exp_token = '123' }.to raise_error Volcanic::Authenticator::V1::ConfigurationError }
    end

    context 'When invalid expiration application token' do
      it { expect { config.exp_app_token = '123' }.to raise_error Volcanic::Authenticator::V1::ConfigurationError }
    end

    context 'When invalid expiration public key' do
      it { expect { config.exp_public_key = '123' }.to raise_error Volcanic::Authenticator::V1::ConfigurationError }
    end
  end

  describe 'Helper' do
    let(:set) { Volcanic::Authenticator.config }
    let(:cache) { Volcanic::Cache::Cache.instance }

    describe 'Application Token' do
      before { Configuration.set }
      let(:app_token) { Volcanic::Authenticator::V1::AppToken }
      subject { app_token.request_app_token }

      context 'when missing app_name' do
        before { set.app_name = nil }
        it { expect { app_token.request_app_token }.to raise_error Volcanic::Authenticator::V1::ApplicationTokenError }
      end

      context 'when invalid app_name' do
        before { set.app_secret = 'wrong_name' }
        it { expect { app_token.request_app_token }.to raise_error Volcanic::Authenticator::V1::AuthorizationError }
      end

      context 'when missing app_secret' do
        before { set.app_secret = nil }
        it { expect { app_token.request_app_token }.to raise_error Volcanic::Authenticator::V1::ApplicationTokenError }
      end

      context 'when invalid app_secret' do
        before { set.app_secret = 'wrong_secret' }
        it { expect { app_token.request_app_token }.to raise_error Volcanic::Authenticator::V1::AuthorizationError }
      end

      context 'When requesting' do
        it { should_not be nil }
      end

      context 'When fetch and requesting' do
        subject { app_token.fetch_and_request }
        it { should_not be nil }
        # it { expect(cache.fetch('volcanic_application_token')).not_to be nil }
      end
    end

    describe 'Public Key' do
      before { Configuration.set }
      let(:key) { Volcanic::Authenticator::V1::Key }
      let(:kid) { '0b0dcb1b988e36701454dfd8bda4431e' }
      subject { key.request_public_key(kid) }

      context 'When failed to generate application token' do
        before { set.app_secret = nil }
        it { expect { key.request_public_key(kid) }.to raise_error Volcanic::Authenticator::V1::ApplicationTokenError }
      end

      context 'When fetch and requesting' do
        subject { key.fetch_and_request(kid) }
        it { should_not be nil }
        it { expect(cache.fetch('volcanic_public_key')).not_to be nil }
      end
    end
  end
end
