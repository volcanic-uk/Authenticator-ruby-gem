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
  let(:tokens) { JSON.parse(Configuration.mock_tokens) }
  let(:mock_token_base64) { tokens['token'] }
  let(:mock_token_base64_2) { tokens['token_2'] }
  let(:mock_token_base64_exp) { tokens['expired_token'] }
  let(:mock_token_base64_invalid) { tokens['token_4'] }

  describe '#initialize' do
    context 'When token is nil/empty' do
      it { expect { token.new(nil) }.to raise_error token_error }
      it { expect { token.new('') }.to raise_error token_error }
    end

    context 'When invalid token' do
      it { expect { token.new('wrong-token') }.to raise_error token_error }
    end

    context 'When token is invalid structure' do
      payload = { body: '1234' }
      auth_token = JWT.encode payload, nil, 'none'
      it { expect { token.new(auth_token) }.to raise_error token_error }
    end

    context 'When token is valid' do
      # initialize token by using a mock token at spec/mock_tokens.json
      subject { token.new(mock_token_base64) }
      # below information are claims and details extract from the mock_token
      its(:token_key) { mock_token_base64 }
      its(:kid) { should eq 'a5f53fa25f2f82a3843c4af11bd801a1' }
      its(:exp) { should eq 7_571_210_994 }
      its(:sub) { should eq 'user://sandbox/-1/1/1/2' }
      its(:nbf) { should eq 1_571_211_054 }
      its(:audience) { should eq %w[krakatoaeu -] }
      its(:iat) { should eq 1_571_211_054 }
      its(:iss) { should eq 'volcanic_auth_service_ap2' }
      its(:jti) { should eq nil }
      its(:dataset_id) { should eq '-1' }
      its(:principal_id) { should eq '1' }
      its(:identity_id) { should eq '1' }
    end
  end

  describe '#validate' do
    context 'When expired token key' do
      it { expect(token.new(mock_token_base64_exp).validate).to be false }
    end

    context 'When invalid signature' do
      it { expect(token.new(mock_token_base64_invalid).validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(mock_token_base64).validate).to be true }
    end
  end

  describe '#remote_validate' do
    context 'When expire token key' do
      it { expect(token.new(mock_token_base64_exp).remote_validate).to be false }
    end

    context 'When invalid signature' do
      it { expect(token.new(mock_token_base64_invalid).remote_validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(mock_token_base64).remote_validate).to be true }
    end
  end

  describe '#revoke' do
    context 'When success' do
      before { token.new(mock_token_base64_2).revoke! }
      it { expect(token.new(mock_token_base64_2).remote_validate).to be false }
    end
  end
end
