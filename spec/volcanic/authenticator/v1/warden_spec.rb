# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::Warden, :vcr do
  before { Configuration.set }
  let(:mock_request) { double 'request' }
  let(:strategy) {}
  let(:tokens) { JSON.parse(Configuration.mock_tokens) } # get token key
  let(:token) { tokens['valid_token'] }
  let(:invalid_token) { tokens['invalid_token'] }
  let(:expired_token) { tokens['invalid_token'] }
  let(:session_token) { { auth_token: tokens['valid_token'] } }
  let(:has_header) { true }
  let(:auth_header) { "Bearer #{token}" }

  before do
    allow(mock_request).to receive(:headers).and_return(auth_header)
    allow(mock_request).to receive(:has_header?).with('HTTP_AUTHORIZATION').and_return(has_header)
    allow(mock_request).to receive(:get_header).with('HTTP_AUTHORIZATION').and_return(auth_header)
    allow(strategy).to receive(:request).and_return(mock_request)
    allow(strategy).to receive(:session).and_return(session_token)
  end

  subject { strategy.authenticate! }

  describe '#allow_always' do
    let(:strategy) { Volcanic::Authenticator::Warden::AllowAlways.new(nil) }

    context 'when auth header and session token not exist' do
      let(:has_header) { false }
      let(:session_token) { nil }
      it { should eq :success }
    end

    context 'when only auth header exist' do
      let(:session_token) { nil }
      it { should eq :success }
    end

    context 'when only session token exist' do
      let(:has_header) { false }
      it { should eq :success }
    end

    context 'when valid token' do
      it { should eq :success }
    end

    context 'when token is invalid' do
      let(:token) { tokens['invalid_token'] }
      it { should eq :success }
    end
  end

  describe '#validate_token' do
    let(:strategy) { Volcanic::Authenticator::Warden::ValidateToken.new(nil) }

    context 'when HTTP_AUTHORIZATION header is missing' do
      let(:has_header) { false }
      it { expect(strategy.valid?).to eq false }
    end

    context 'when HTTP_AUTHORIZATION header is not missing' do
      let(:has_header) { true }
      it { expect(strategy.valid?).to eq true }
    end

    context 'when token invalid' do
      context 'token is nil' do
        let(:auth_header) { nil }
        it { should eq :failure }
      end

      context 'token is empty' do
        let(:token) { '' }
        it { should eq :failure }
      end

      context 'invalid structure' do
        let(:token) { 'invalid_auth_pattern' }
        it { should eq :failure }
      end

      context 'auth header forbidden' do
        let(:token) { invalid_token }
        it { should eq :failure }
      end

      context 'token is not authenticated by auth' do
        before do
          stub_request(:post, 'http://localhost:6000/api/v1/token/validate')
            .with(headers: { 'Authorization' => "Bearer #{token}" })
            .to_return(status: 401)
        end

        let(:token) { expired_token }
        it { should eq :failure }
      end
    end

    context 'when token valid' do
      it { should eq :success }
    end
  end

  describe 'validate_token_present' do
    let(:strategy) { Volcanic::Authenticator::Warden::ValidatePresentToken.new(nil) }

    context 'when HTTP_AUTHORIZATION header is missing' do
      let(:has_header) { false }
      it { expect(strategy.valid?).to eq true }
    end

    context 'when HTTP_AUTHORIZATION header is not missing' do
      let(:has_header) { true }
      it { expect(strategy.valid?).to eq true }
    end

    # not eq :failure because the strategy is passes
    context 'when token invalid' do
      context 'token is nil' do
        let(:auth_header) { nil }
        it { should_not eq :failure }
      end

      context 'token is empty' do
        let(:token) { '' }
        it { should_not eq :failure }
      end

      context 'invalid structure' do
        let(:token) { 'invalid_auth_pattern' }
        it { should_not eq :failure }
      end

      # only valid structure is send to auth service for validation
      context 'auth header forbidden' do
        let(:token) { invalid_token }
        it { should eq :failure }
      end
    end

    context 'when token valid' do
      it { should eq :success }
    end
  end

  describe '#validate_session_token' do
    let(:strategy) { Volcanic::Authenticator::Warden::ValidateSessionToken.new(nil) }

    # not eq :failure because the strategy is passes
    context 'when token invalid' do
      context 'token is nil' do
        let(:session_token) { { auth_token: nil } }
        it { should eq :failure }
      end

      context 'token is empty' do
        let(:session_token) { { auth_token: nil } }
        it { should eq :failure }
      end

      context 'invalid structure' do
        let(:session_token) { { auth_token: 'invalid_token_pattern' } }
        it { should eq :failure }
      end

      context 'auth header forbidden' do
        let(:session_token) { { auth_token: invalid_token } }
        it { should eq :failure }
      end

      # context 'auth token expired' do
      #   let(:session_token) { { auth_token: tokens['expired_token'] } }
      #   subject { strategy.valid? }
      #   it { should eq false }
      # end
    end

    context 'when token valid' do
      it { should eq :success }
    end
  end
end
