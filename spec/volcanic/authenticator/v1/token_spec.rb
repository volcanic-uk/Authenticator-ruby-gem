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
  let(:mock_exp_token_key) { tokens['token_3'] }
  let(:mock_invalid_token_key) { tokens['token_4'] }

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
      subject { token.new(mock_token_key) }
      its(:token_key) { mock_token_key }
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

  describe '#create' do
    context 'when invalid credential' do
      it { expect { token.create('wrong-name', 'wrong-secret', 1) }.to raise_error authorization_error }
    end

    context 'when valid credential' do
      subject { token.create(mock_identity_name, mock_identity_secret, 1) }
      its(:token_key) { should eq mock_token_key }
    end
  end

  describe '#create_on_behalf' do
    context 'When invalid/non-exist identity' do
      it { expect { token.create_on_behalf(123_456_789) }.to raise_error token_error }
    end

    context 'When valid identity' do
      subject { token.create_on_behalf(1) }
      its(:token_key) { should eq mock_token_key }
    end

    context 'When set other options' do
      let(:identity_id) { mock_identity_id }
      let(:nbf) { 1_571_356_800_000 } # 18/09/2019 in miliseconds
      let(:exp) { 1_571_443_200_000 } # 19/09/2019 in miliseconds
      let(:single_use) { true }
      let(:aud) { ['auth'] }
      subject { token.create_on_behalf(identity_id, nbf: nbf, exp: exp, single_use: single_use, audience: aud) }
      its(:jti) { should eq 'caea0310-f029-11e9-ada9-212b594571b6' }
      its(:nbf) { should eq 1_571_356_800 }
      its(:exp) { should eq 1_571_326_190 }
      its(:audience) { should eq ['auth'] }
    end

    context 'When non-single use token' do
      subject { token.create_on_behalf(mock_identity_id, single_use: false) }
      its(:jti) { should eq nil }
    end
  end

  describe '#validate' do
    context 'When expired token key' do
      it { expect(token.new(mock_exp_token_key).validate).to be false }
    end

    context 'When invalid signature' do
      it { expect(token.new(mock_invalid_token_key).validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(mock_token_key).validate).to be true }
    end
  end

  describe '#remote_validate' do
    context 'When expire token key' do
      it { expect(token.new(mock_exp_token_key).remote_validate).to be false }
    end

    context 'When invalid signature' do
      it { expect(token.new(mock_invalid_token_key).remote_validate).to be false }
    end

    context 'When token is valid' do
      it { expect(token.new(mock_token_key).remote_validate).to be true }
    end
  end

  describe '#revoke' do
    context 'When success' do
      before { token.new(mock_token_key_2).revoke! }
      it { expect(token.new(mock_token_key_2).remote_validate).to be false }
    end
  end
end
