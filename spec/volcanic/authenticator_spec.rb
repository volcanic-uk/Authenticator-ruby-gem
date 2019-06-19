# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator do
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

    context 'When invalid expiration value' do
      it { expect { config.exp_token = '123' }.to raise_error Volcanic::Authenticator::V1::ConfigurationError }
    end
  end
end
