# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator, :vcr do
  let(:config) { Volcanic::Authenticator.config }
  let(:app_token) { Volcanic::Authenticator::V1::AppToken }
  let(:configuration_error) { Volcanic::Authenticator::V1::ConfigurationError }
  let(:app_token_error) { Volcanic::Authenticator::V1::ApplicationTokenError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  describe 'Config' do
    context 'When missing auth url' do
      before { Configuration.reset }
      it { expect { config.auth_url }.to raise_error configuration_error }
    end

    context 'When invalid expiration token' do
      it { expect { config.exp_token = '123' }.to raise_error configuration_error }
    end

    context 'When invalid expiration application token' do
      it { expect { config.exp_app_token = '123' }.to raise_error configuration_error }
    end

    context 'When invalid expiration public key' do
      it { expect { config.exp_public_key = '123' }.to raise_error configuration_error }
    end

    context 'When auth_url is nil' do
      before { config.auth_url = nil }
      it { expect { config.auth_url }.to raise_error configuration_error }
    end

    context 'When auth_enable is non boolean value' do
      it { expect { config.auth_enabled = nil }.to raise_error configuration_error }
      it { expect { config.auth_enabled = '' }.to raise_error configuration_error }
      it { expect { config.auth_enabled = 1234 }.to raise_error configuration_error }
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
        it { expect { app_token.request_app_token }.to raise_error app_token_error }
      end

      context 'when invalid app_name' do
        before { set.app_secret = 'wrong_name' }
        it { expect { app_token.request_app_token }.to raise_error authorization_error }
      end

      context 'when missing app_secret' do
        before { set.app_secret = nil }
        it { expect { app_token.request_app_token }.to raise_error app_token_error }
      end

      context 'when invalid app_secret' do
        before { set.app_secret = 'wrong_secret' }
        it { expect { app_token.request_app_token }.to raise_error authorization_error }
      end

      context 'When requesting' do
        it { should_not be nil }
      end

      context 'When fetch and requesting' do
        subject { app_token.fetch_and_request }
        it { should_not be nil }
      end

      context 'When app_dataset_id is nil' do
        before { set.app_dataset_id = nil }
        it { expect { app_token.request_app_token }.to raise_error app_token_error }
      end

      context 'When app_dataset_id is empty' do
        before { set.app_dataset_id = '' }
        it { expect { app_token.request_app_token }.to raise_error app_token_error }
      end
    end

    describe 'Public Key' do
      before { Configuration.set }
      let(:key) { Volcanic::Authenticator::V1::Key }
      let(:kid) { '0b0dcb1b988e36701454dfd8bda4431e' }
      subject { key.request_public_key(kid) }

      context 'When failed to generate application token' do
        before { set.app_secret = nil }
        it { expect { key.request_public_key(kid) }.to raise_error app_token_error }
      end

      context 'When fetch and requesting' do
        subject { key.fetch_and_request(kid) }
        it { should_not be nil }
        it { expect(cache.fetch(kid)).not_to be nil }
      end
    end
  end
end
