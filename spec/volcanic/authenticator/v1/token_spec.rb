# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Token, :vcr do
  let(:mock_name) { SecureRandom.hex(6) }
  let(:identity) { Volcanic::Authenticator::V1::Identity.register(mock_name, 1) }
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  let(:token_error) { Volcanic::Authenticator::V1::TokenError }
  subject(:new_token) { Volcanic::Authenticator::V1::Token.create(identity.name, identity.secret) }

  describe 'Create' do
    context 'When name is missing' do
      it { expect { token.create(nil, identity.secret) }.to raise_error identity_error }
      it { expect { token.create('', identity.secret) }.to raise_error identity_error }
    end

    context 'When secret is missing' do
      it { expect { token.create(identity.name, nil) }.to raise_error identity_error }
      it { expect { token.create(identity.name, '') }.to raise_error identity_error }
    end

    context 'When invalid name or secret' do
      it { expect { token.create('wrong-name', identity.secret) }.to raise_error authorization_error }
      it { expect { token.create(identity.name, 'wrong-secret') }.to raise_error authorization_error }
    end

    context 'When success' do
      its(:token_key) { should_not be nil }
    end
  end

  describe 'Validate' do
    context 'When missing token' do
      it { expect(token.new(nil).validate).to be false }
      it { expect(token.new('').validate).to be false }
    end

    context 'When invalid token' do
      it { expect(token.new('wrong-token').validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(new_token.token_key).validate).to be true }
    end
  end

  describe 'Validate by Auth service' do
    context 'When missing token' do
      it { expect(token.new(nil).validate_by_service).to be false }
      it { expect(token.new('').validate_by_service).to be false }
    end

    context 'When invalid token' do
      it { expect(token.new('wrong-token').validate_by_service).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(new_token.token_key).validate_by_service).to be true }
    end
  end

  describe 'Claims' do
    subject { new_token.decode_and_fetch_claims }

    context 'When success' do
      its(:token_key) { should_not be nil }
      its(:kid) { should_not be nil }
      its(:sub) { should_not be nil }
      its(:iss) { should_not be nil }
      # its(:dataset_id) { should_not be nil } # this can be either nil or not
      # its(:principal_id) { should_not be nil } # this can be either nil or not
      its(:identity_id) { should_not be nil }
    end
  end

  describe 'Revoke' do
    before { new_token.cache! }
    subject { new_token.revoke! }
    context 'When token is invalid' do
      it { expect { token.new('').revoke! }.to raise_error authorization_error }
      it { expect { token.new(nil).revoke! }.to raise_error authorization_error }
    end

    context 'When invalid token' do
      it { expect { token.new('wrong-token').revoke! }.to raise_error authorization_error }
    end

    context 'When revoked' do
      it { should_not be raise_error }
    end
  end
end
