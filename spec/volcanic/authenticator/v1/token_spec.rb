# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Token do
  before { Configuration.set }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:identity) { Volcanic::Authenticator::V1::Identity.create(mock_name) }
  subject(:new_token) { token.create(identity.name, identity.secret) }
  describe 'Creating' do
    context 'When name is missing' do
      it { expect { token.create(nil, identity.secret) }.to raise_error Volcanic::Authenticator::TokenError }
      it { expect { token.create('', identity.secret) }.to raise_error Volcanic::Authenticator::TokenError }
    end

    context 'When secret is missing' do
      it { expect { token.create(identity.name, nil) }.to raise_error Volcanic::Authenticator::TokenError }
      it { expect { token.create(identity.name, '') }.to raise_error Volcanic::Authenticator::TokenError }
    end

    context 'When invalid name or secret' do
      it { expect { token.create('wrong-name', identity.secret) }.to raise_error Volcanic::Authenticator::TokenError }
      it { expect { token.create(identity.name, 'wrong-secret') }.to raise_error Volcanic::Authenticator::TokenError }
    end

    context 'When success' do
      it { is_expected.to be_an identity }
      it(:token) { should_not be nil }
    end
  end

  describe 'Cache a token' do
    subject { new_token.cache! }
    it { should_not be raise_error }
  end

  describe 'Validate' do
    subject { new_token.validate }
    context 'When token is invalid' do
      it { expect { token.new(nil).validate }.to be false }
      it { expect { token.new('').validate }.to be false }
      it { expect { token.new('wrong-token').validate }.to be false }
    end

    context 'When token is valid' do
      it { should be true }
    end
  end

  describe 'Validate by Auth service' do
    subject { new_token.validate_by_service }
    context 'When token is invalid' do
      it { expect { token.new(nil).validate_by_service }.to be false }
      it { expect { token.new('').validate_by_service }.to be false }
      it { expect { token.new('wrong-token').validate_by_service }.to be false }
    end

    context 'When token is valid' do
      it { should be true }
    end
  end

  describe 'Get claims' do
    subject { new_token.decode_and_fetch_claims }

    context 'When success' do
      its(:token) { should_not be nil }
      its(:kid) { should_not be nil }
      its(:sub) { should_not be nil }
      its(:iss) { should_not be nil }
      # its(:dataset_id) { should_not be nil } # this can be either nil or not
      # its(:principal_id) { should_not be nil } # this can be either nil or not
      its(:identity_id) { should_not be nil }
    end
  end

  describe 'Revoke token' do
    before { new_token.cache! }
    subject { new_token.revoke! }
    context 'When token is invalid' do
      it { expect { token.new('').revoke! }.to raise_error Volcanic::Authenticator::TokenError }
      it { expect { token.new(nil).revoke! }.to raise_error Volcanic::Authenticator::TokenError }
      it { expect { token.new('wrong-token').revoke! }.to raise_error Volcanic::Authenticator::TokenError }
    end

    context 'When success' do
      it { should_not be raise_error }
    end
  end
end
