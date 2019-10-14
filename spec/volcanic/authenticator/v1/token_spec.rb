# frozen_string_literal: true

require 'jwt'

RSpec.describe Volcanic::Authenticator::V1::Token, :vcr do
  before { Configuration.set }
  let(:mock_identity_name) { 'mock_identity_name' }
  let(:mock_identity_id) { 1 }
  let(:mock_identity_secret) { 'mock_identity_secret' }
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:token_error) { Volcanic::Authenticator::V1::TokenError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  let(:tokens) { JSON.parse(Configuration.token_json) }
  let(:mock_token_key) { tokens['token'] }
  let(:mock_token_key_2) { tokens['token_2'] }
  let(:mock_invalid_token_key) { tokens['token_3'] }
  let(:mock_expired_token_key) { tokens['token_4'] }

  describe 'Create token' do
    it { expect(token.create(mock_identity_name, mock_identity_secret, 1).token_key).to eq mock_token_key }
  end

  describe 'Create token by identity' do
    context 'default setting' do
      it { expect(token.request(mock_identity_id).token_key).to eq mock_token_key }
    end

    context 'nbf and exp in date format' do
      let(:nbf) { '09/01/2019' }
      let(:exp) { '09/02/2019' }
      it { expect(token.request(mock_identity_id, nbf: nbf, exp: exp).token_key).to eq mock_token_key }
    end
  end

  describe 'Validate' do
    context 'When missing token key' do
      it { expect { token.new(nil).validate }.to raise_error token_error }
      it { expect { token.new('').validate }.to raise_error token_error }
    end

    context 'When invalid token key' do
      it { expect { token.new('wrong-token-key').validate }.to raise_error token_error }
    end

    context 'When expired token key' do
      it { expect(token.new(mock_expired_token_key).validate).to be false }
    end

    context 'When invalid signature' do
      it { expect(token.new(mock_invalid_token_key).validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(mock_token_key).validate).to be true }
    end
  end

  describe 'Validate by service' do
    context 'When missing token key' do
      it { expect { token.new(nil).remote_validate }.to raise_error token_error }
      it { expect { token.new('').remote_validate }.to raise_error token_error }
      it { expect { token.new('wrong-id').remote_validate }.to raise_error token_error }
    end

    context 'When expire token key' do
      it { expect(token.new(mock_expired_token_key).remote_validate).to be false }
    end

    context 'When invalid signature' do
      it { expect(token.new(mock_invalid_token_key).remote_validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(mock_token_key).remote_validate).to be true }
    end
  end

  describe 'Decodes and fetch claims' do
    context 'When invalid token key' do
      it { expect { token.new(nil).fetch_claims }.to raise_error token_error }
      it { expect { token.new('wrong-token').fetch_claims }.to raise_error token_error }
    end

    context 'When success' do
      subject { token.new(mock_token_key_2).fetch_claims }
      its(:kid) { should eq 'a5f53fa25f2f82a3843c4af11bd801a1' }
      its(:sub) { should eq 'user://sandbox/-1/1/1/2' }
      its(:iss) { should eq 'volcanic_auth_service_ap2' }
      its(:dataset_id) { should eq(-1) }
      its(:subject_id) { should eq 2 }
      its(:principal_id) { should eq 1 }
      its(:identity_id) { should eq 1 }
    end
  end

  describe 'Revoke token' do
    context 'When token is invalid' do
      it { expect { token.new(nil).revoke! }.to raise_error token_error }
      it { expect { token.new('').revoke! }.to raise_error token_error }
      it { expect { token.new('wrong-token').revoke! }.to raise_error token_error }
    end

    context 'When success' do
      before { token.new(mock_token_key).revoke! }
      it { expect(token.new(mock_token_key).remote_validate).to be false }
    end
  end

  describe '.authorize' do
    let(:permission) { 'jobs' }
    let(:action) { 'create' }
    context 'when missing permission' do
      it { expect(token.new(mock_token_key).authorize?(nil, action)).to be false }
    end

    context 'when missing action' do
      it { expect(token.new(mock_token_key).authorize?(permission, nil)).to be false }
    end

    context 'when authorised' do
      it { expect(token.new(mock_token_key).authorize?(permission, action)).to be false }
    end
  end
end
