# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator, :vcr do
  describe 'Config' do
    let(:config) { Volcanic::Authenticator.config }
    context 'When missing auth url' do
      it { expect(config.auth_url).to be nil }
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
    before { Configuration.set }
    let(:cache) { Volcanic::Cache::Cache.instance }

    describe 'Application Token' do
      let(:app_token) { Volcanic::Authenticator::V1::AppToken }

      context 'When requesting' do
        subject { app_token.request_app_token }
        it { should_not be nil }
      end

      context 'When fetch and requesting' do
        subject { app_token.fetch_and_request }
        it { should_not be nil }
        it { expect(cache.fetch('volcanic_application_token')).not_to be nil }
      end
    end

    describe 'Public Key' do
      let(:key) { Volcanic::Authenticator::V1::Key }

      context 'When requesting' do
        subject { key.request_public_key }
        it { should_not be nil }
      end

      context 'When fetch and requesting' do
        subject { key.fetch_and_request }
        it { should_not be nil }
        it { expect(cache.fetch('volcanic_public_key')).not_to be nil }
      end
    end
  end
end
