# frozen_string_literal: true

require 'jwt'

RSpec.describe Volcanic::Authenticator::V1::Identity, :vcr do
  before { Configuration.set }
  let(:mock_name) { 'mock_identity_name' }
  let(:mock_secret) { 'mock_identity_secret' }
  let(:principal_id) { 1 } # need to create mock principal
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  describe 'Create' do
    context 'When missing name' do
      it { expect { identity.register(nil, principal_id) }.to raise_error identity_error }
      it { expect { identity.register('', principal_id) }.to raise_error identity_error }
    end

    context 'When duplicate name' do
      before { identity.register(mock_name, principal_id, mock_secret) }
      it { expect { identity.register(mock_name, principal_id, mock_secret) }.to raise_error identity_error }
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
      its(:name) { should eq mock_name }
      its(:principal_id) { should eq principal_id }
    end

    context 'When custom secret' do
      subject { identity.register(mock_name, principal_id, mock_secret) }
      its(:secret) { should eq mock_secret }
    end

    context 'When secret is nil' do
      subject { identity.register(mock_name, principal_id) }
      its(:secret) { should eq '0f5768c55debdee22fe9aa7b6a928e9d40e67780' }
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
