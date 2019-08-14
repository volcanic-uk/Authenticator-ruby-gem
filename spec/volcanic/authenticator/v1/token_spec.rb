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
  let(:mock_token_key_2) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE1NjUzNjA4MTgsInN1YiI6InVzZXI6Ly9zYW5kYm94Ly0xLzEvMS8yIiwibmJmIjoxNTY1MTQ0ODE4LCJhdWRpZW5jZSI6WyJrcmFrYXRvYWV1IiwiLSJdLCJpYXQiOjE1NjUxNDQ4MTgsImlzcyI6InZvbGNhbmljX2F1dGhfc2VydmljZV9hcDIifQ.AZYltVb1DF1Mjf2g0iJEeod-BA3hsHOj8l7wLxCaLBJAa4xik7gZmy_q2xEzxbdQlsFhf9G9DeJxCBCa6IXb6Y4rAefxqvVU9a-p5cv8ORO2cxZMqH6qq3_CqwPDM4yGiProUPJcNCDnTl4miFAu80MHy7-bF7PCakRNQ7EJKnLl_68u' }
  let(:mock_invalid_token_key) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE5OTQ4MTM5NjQsInN1YiI6InVzZXI6Ly91bmRlZmluZWQvbnVsbC8xLzEvMiIsIm5iZiI6MTU2MjgxMzk2NCwiYXVkaWVuY2UiOlsia3Jha2F0b2FldSIsIi0iXSwiaWF0IjoxNTYyODEzOTY0LCJpc3MiOiJ2b2xjYW5pY19hdXRoX3NlcnZpY2VfYXAyIn0.AG0N6LB2EL99-1o_BeSKIX124JNeo02SW-YoNOxW5fva3j_GJdoc7NT2MC_XBiEvJbPVz6ykJmdEt-_hqOh45mtFAe0IFp4MGPRoXMx238LKw6qGyyUE7NL0VMTEhMjufyAcORqODK_aJse6PSFtL5Vopgnjn8lICh7pmshMdWJIQEB' }
  let(:mock_expired_token_key) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE1NjI4MTU2MDEsInN1YiI6InVzZXI6Ly91bmRlZmluZWQvbnVsbC8xLzEvMiIsIm5iZiI6MTU2MjgxNTYwMSwiYXVkaWVuY2UiOlsia3Jha2F0b2FldSIsIi0iXSwiaWF0IjoxNTYyODE1NjAxLCJpc3MiOiJ2b2xjYW5pY19hdXRoX3NlcnZpY2VfYXAyIn0.ARlJIfffiPQM_fDJ6uJLrOv1yYa-jHtg38ZWR74_6T0fM7YlBC_SFcGj8Rgsb4RJg8RFAc5DZ9fGP1iYvzt-5xG3AcsW9cG-sTtOoCilwDbOfV0tAmaz7t45ZTTvmC_MUM62kFp-V2dlxYZkwNqPre2TOKHrzj7lhz6mSxNINOcP1mLj' }

  describe 'Create token' do
    it { expect(token.create(mock_identity_name, mock_identity_secret).token_key).to eq mock_token_key }
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
      subject { token.new(mock_token_key_2).fetch_claims }
      its(:kid) { should eq 'a5f53fa25f2f82a3843c4af11bd801a1' }
      its(:sub) { should eq 'user://sandbox/-1/1/1/2' }
      its(:iss) { should eq 'volcanic_auth_service_ap2' }
      its(:dataset_id) { should eq(-1) }
      its(:subject_id) { should eq 1 }
      its(:principal_id) { should eq 1 }
      its(:identity_id) { should eq 2 }
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
