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
      mock_header = { kid: mock_kid = 'mock_kid' }
      mock_body = {
        exp: mock_exp = Time.now.to_i,
        sub: mock_sub = 'user://sandbox/mock_dataset_id/mock_principal_id/mock_identity_id',
        nbf: mock_nbf = Time.now.to_i,
        aud: mock_aud = ['mock_aud'],
        iat: mock_iat = Time.now.to_i,
        iss: mock_iss = 'mock_iss',
        jti: mock_jti = 'mock_jti'
      }
      mock_token = JWT.encode(mock_body, nil, 'none', mock_header)

      subject { token.new(mock_token) }
      its(:token_key) { mock_token }
      its(:kid) { should eq mock_kid }
      its(:exp) { should eq mock_exp }
      its(:sub) { should eq mock_sub }
      its(:nbf) { should eq mock_nbf }
      its(:aud) { should eq mock_aud }
      its(:iat) { should eq mock_iat }
      its(:iss) { should eq mock_iss }
      its(:jti) { should eq mock_jti }
      its(:dataset_id) { should eq 'mock_dataset_id' }
      its(:principal_id) { should eq 'mock_principal_id' }
      its(:identity_id) { should eq 'mock_identity_id' }
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

  describe '#revoke!' do
    let(:mock_claims) { { exp: 1_589_587_408, sub: 'user://sandbox/-1/volcanic/volcanic', nbf: 1_589_527_409, aud: ['*'], iat: 1_589_527_409, iss: 'volcanic_auth_service_ap2' } }
    let(:mock_token_base64) { tokens['mock_token'] }
    let(:expected_path) { 'api/v1/token/cb40523b3039081d36d86d37b3723e0f' }
    let(:token_instance) {}
    let(:response) { { 'messages': 'token destroyed successfully' } }

    before { allow(token_instance).to receive(:perform_delete_and_parse).with(anything, expected_path).and_return(response) }

    context 'valid params' do
      subject { token_instance.revoke! }

      context 'by token_base64 string' do
        let(:token_instance) { token.new(mock_token_base64) }
        it { should eq response }
      end

      context 'by token claims' do
        let(:token_instance) { token.new(mock_claims) }
        it { should eq response }
      end
    end

    context 'incorrect params' do
      context 'by token_base64 string' do
        let(:invalid_mock_token_base64) { tokens['invalid_token'] }
        let(:token_instance) { token.new(invalid_mock_token_base64) }
        it { expect { token_instance.revoke! }.to raise_error RSpec::Mocks::MockExpectationError }
      end

      context 'by token claims' do
        let(:invalid_mock_claims) { { sub: 'user://sandbox/-1/volcanic/volcanic' } }
        let(:token_instance) { token.new(invalid_mock_claims) }
        it { expect { token_instance.revoke! }.to raise_error RSpec::Mocks::MockExpectationError }
      end
    end
  end

  describe '#get_privileges_for_service' do
    let(:service) { 'ats' }
    let(:sub) { 'user://stack/dataset/principal/identity' }
    let(:all_privileges) { JSON.parse(privileges_json)['response'] }
    let(:privileges_json) { File.read('./spec/privileges-for-ats.json') }

    subject { token.new(mock_token_base64).get_privileges_for_service(service) }

    context 'when a service is defined' do
      before(:each) do
        allow(Volcanic::Authenticator::V1::Subject).to receive(:perform_get_and_parse) do
          all_privileges
        end
      end

      it 'returns data' do
        expect(subject).to be_a_kind_of(Array)
      end
    end

    context 'when a service is not defined' do
      before do
        allow(Volcanic::Authenticator::V1::Subject).to receive(:perform_get_and_parse) do
          []
        end
      end

      let(:service) { 'not-a-service' }

      it 'returns correctly' do
        expect(subject).to eq([])
      end
    end
  end

  describe '#identity' do
    subject(:identity) { token.identity }

    let(:token_string) { JWT.encode({ sub: sub_claim }, '') }
    let(:token) { described_class.new(token_string) }

    context 'with a subject that is an identitity' do
      let(:sub_claim) { 'user://stack/ds/princ/ident' }

      its(:stack_id) { is_expected.to eq('stack') }
      its(:dataset_id) { is_expected.to eq('ds') }
      its(:principal_id) { is_expected.to eq('princ') }
      its(:id) { is_expected.to eq('ident') }
    end

    context 'with a subject that is just a principal' do
      let(:sub_claim) { 'user://stack/ds/princ' }

      it { is_expected.to be_nil }
    end
  end

  describe '#principal' do
    subject(:principal) { token.principal }

    let(:token_string) { JWT.encode({ sub: sub_claim }, '') }
    let(:token) { described_class.new(token_string) }

    context 'with a subject that is an identitity' do
      let(:sub_claim) { 'user://stack/ds/princ/ident' }

      its(:stack_id) { is_expected.to eq('stack') }
      its(:dataset_id) { is_expected.to eq('ds') }
      its(:id) { is_expected.to eq('princ') }
    end

    context 'with a subject that is just a principal' do
      let(:sub_claim) { 'user://stack/ds/princ' }

      its(:stack_id) { is_expected.to eq('stack') }
      its(:dataset_id) { is_expected.to eq('ds') }
      its(:id) { is_expected.to eq('princ') }
    end

    context 'with a subject that does not identify as a principal or identity' do
      let(:sub_claim) { 'user://stack/ds' }

      it { is_expected.to be_nil }
    end
  end

  describe '#subject' do
    subject { token.subject }

    let(:token_string) { JWT.encode({ sub: sub_claim }, '') }
    let(:token) { described_class.new(token_string) }

    context 'with a subject that is an identity' do
      let(:sub_claim) { 'user://stack/ds/princ/ident' }

      its(:stack_id) { is_expected.to eq('stack') }
      its(:dataset_id) { is_expected.to eq('ds') }
      its(:principal_id) { is_expected.to eq('princ') }
      its(:id) { is_expected.to eq('ident') }
      it { is_expected.to be_a(Volcanic::Authenticator::V1::Identity) }
    end

    context 'with a subject that is just a principal' do
      let(:sub_claim) { 'user://stack/ds/princ' }

      its(:stack_id) { is_expected.to eq('stack') }
      its(:dataset_id) { is_expected.to eq('ds') }
      its(:id) { is_expected.to eq('princ') }

      it { is_expected.to be_a(Volcanic::Authenticator::V1::Principal) }
    end

    context 'with a subject that does not identify as a principal or identity' do
      let(:sub_claim) { 'user://stack/ds' }

      it { is_expected.to be_nil }
    end
  end
end

def mock_token; end
