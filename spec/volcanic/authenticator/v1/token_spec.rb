# frozen_string_literal: true

require 'jwt'

RSpec.describe Volcanic::Authenticator::V1::Token, :vcr do
  before { Configuration.set }
  let(:mock_identity_name) { 'mock_identity_name' }
  let(:mock_identity_secret) { 'mock_identity_secret' }
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:token_error) { Volcanic::Authenticator::V1::TokenError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  let(:mock_token_key) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE5OTQ4MTM5NjQsInN1YiI6InVzZXI6Ly91bmRlZmluZWQvbnVsbC8xLzEvMiIsIm5iZiI6MTU2MjgxMzk2NCwiYXVkaWVuY2UiOlsia3Jha2F0b2FldSIsIi0iXSwiaWF0IjoxNTYyODEzOTY0LCJpc3MiOiJ2b2xjYW5pY19hdXRoX3NlcnZpY2VfYXAyIn0.AG0N6LB2EL99-1o_BeSKIX124JNeo02SW-YoNOxW5fva3j_GJdoc7NT2MC_XBiEvJbPVz6ykJmdEt-_hqOh45mtFAe0IFp4MGPRoXMx238LKw6qGyyUE7NL0VMTEhMjufyAcORqODK_aJse6PSFtL5Vopgnjn8lICh7pmshMdWJIQEB2' }
  let(:mock_invalid_token_key) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE5OTQ4MTM5NjQsInN1YiI6InVzZXI6Ly91bmRlZmluZWQvbnVsbC8xLzEvMiIsIm5iZiI6MTU2MjgxMzk2NCwiYXVkaWVuY2UiOlsia3Jha2F0b2FldSIsIi0iXSwiaWF0IjoxNTYyODEzOTY0LCJpc3MiOiJ2b2xjYW5pY19hdXRoX3NlcnZpY2VfYXAyIn0.AG0N6LB2EL99-1o_BeSKIX124JNeo02SW-YoNOxW5fva3j_GJdoc7NT2MC_XBiEvJbPVz6ykJmdEt-_hqOh45mtFAe0IFp4MGPRoXMx238LKw6qGyyUE7NL0VMTEhMjufyAcORqODK_aJse6PSFtL5Vopgnjn8lICh7pmshMdWJIQEB' }
  let(:mock_expired_token_key) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE1NjI4MTU2MDEsInN1YiI6InVzZXI6Ly91bmRlZmluZWQvbnVsbC8xLzEvMiIsIm5iZiI6MTU2MjgxNTYwMSwiYXVkaWVuY2UiOlsia3Jha2F0b2FldSIsIi0iXSwiaWF0IjoxNTYyODE1NjAxLCJpc3MiOiJ2b2xjYW5pY19hdXRoX3NlcnZpY2VfYXAyIn0.ARlJIfffiPQM_fDJ6uJLrOv1yYa-jHtg38ZWR74_6T0fM7YlBC_SFcGj8Rgsb4RJg8RFAc5DZ9fGP1iYvzt-5xG3AcsW9cG-sTtOoCilwDbOfV0tAmaz7t45ZTTvmC_MUM62kFp-V2dlxYZkwNqPre2TOKHrzj7lhz6mSxNINOcP1mLj' }

  describe 'Create token' do
    it { expect(token.create(mock_identity_name, mock_identity_secret)).to eq mock_token_key }
  end

  describe 'Generate new token key' do
    context 'When name is missing' do
      it { expect { token.new.gen_token_key(nil, mock_identity_secret) }.to raise_error token_error }
      it { expect { token.new.gen_token_key('', mock_identity_secret) }.to raise_error token_error }
    end

    context 'When secret is missing' do
      it { expect { token.new.gen_token_key(mock_identity_name, nil) }.to raise_error token_error }
      it { expect { token.new.gen_token_key(mock_identity_name, '') }.to raise_error token_error }
    end

    context 'When invalid name or secret' do
      it { expect { token.new.gen_token_key('wrong-name', mock_identity_secret) }.to raise_error authorization_error }
      it { expect { token.new.gen_token_key(mock_identity_name, 'wrong-secret') }.to raise_error authorization_error }
    end

    context 'When success' do
      subject { token.new.gen_token_key(mock_identity_name, mock_identity_secret) }
      its(:token_key) { should eq mock_token_key }
    end
  end

  describe 'Validate' do
    context 'When missing token key' do
      it { expect(token.new(nil).validate).to be false }
      it { expect(token.new('').validate).to be false }
    end

    context 'When invalid token key' do
      it { expect(token.new('wrong-token-key').validate).to be false }
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
      it { expect(token.new(nil).remote_validate).to be false }
      it { expect(token.new('').remote_validate).to be false }
      it { expect(token.new('wrong-id').remote_validate).to be false }
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
      it { expect { token.new.fetch_claims }.to raise_error token_error }
      it { expect { token.new('wrong-token').fetch_claims }.to raise_error token_error }
    end

    context 'When success' do
      subject { token.new(mock_token_key).fetch_claims }
      its(:kid) { should eq 'a5f53fa25f2f82a3843c4af11bd801a1' }
      its(:sub) { should eq 'user://undefined/null/1/1/2' }
      its(:iss) { should eq 'volcanic_auth_service_ap2' }
      its(:dataset_id) { should eq 'null' }
      its(:principal_id) { should eq '1' }
      its(:identity_id) { should eq '1' }
    end
  end

  describe 'Revoke token' do
    context 'When token is invalid' do
      it { expect { token.new('').revoke! }.to raise_error authorization_error }
      it { expect { token.new(nil).revoke! }.to raise_error authorization_error }
      it { expect { token.new('wrong-token').revoke! }.to raise_error authorization_error }
    end

    context 'When success' do
      before { token.new(mock_token_key).revoke! }
      it { expect(token.new(mock_token_key).remote_validate).to be false }
    end
  end
end
