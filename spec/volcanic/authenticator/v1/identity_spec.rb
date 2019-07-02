# frozen_string_literal: true

require 'jwt'

RSpec.describe Volcanic::Authenticator::V1::Identity, :vcr do
  before { Configuration.set }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_secret) { SecureRandom.hex(6) }
  let(:principal_id) { 1 } # need to create mock principal
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  describe 'Create' do
    context 'When missing name' do
      it { expect { identity.register(nil, principal_id) }.to raise_error identity_error }
      it { expect { identity.register('', principal_id) }.to raise_error identity_error }
    end

    context 'When duplicate name' do
      let(:name) { SecureRandom.hex(6) }
      before { identity.register(name, principal_id) }
      it { expect { identity.register(name, principal_id) }.to raise_error identity_error }
    end

    context 'When missing principal id' do
      it { expect { identity.register(mock_name, nil) }.to raise_error identity_error }
      it { expect { identity.register(mock_name, '') }.to raise_error identity_error }
    end

    context 'When invalid principal id' do
      it { expect { identity.register(mock_name, 'wrong-id') }.to raise_error identity_error }
    end

    context 'When success' do
      subject { identity.register(mock_name, principal_id) }
      it { should be_an identity }
    end

    context 'When missing secret' do
      subject { identity.register(mock_name, principal_id, nil) }
      its(:secret) { should_not be nil }
    end

    context 'When given secret' do
      subject { identity.register(mock_name, principal_id, mock_secret) }
      its(:secret) { should be mock_secret }
    end

    context 'When request a token with nil secret' do
      subject { identity.register(mock_name, principal_id) }
      its(:token) { should_not be nil }
    end

    context 'When request a token with secret' do
      subject { identity.register(mock_name, principal_id, mock_secret) }
      its(:token) { should_not be nil }
    end
  end

  describe 'Delete' do
    it { expect(identity.register(mock_name, principal_id).deactivate).not_to be raise_error }
  end
end
