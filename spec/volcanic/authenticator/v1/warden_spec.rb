# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Warden, :vcr do
  before { Configuration.set }
  let(:mock_request) { double 'request' }
  let(:strategy) {}
  let(:tokens) { JSON.parse(Configuration.mock_tokens) }
  let(:mock_token_base64) { tokens['token'] }
  let(:mock_auth_header) { "Bearer #{mock_token_base64}" }
  let(:invalid_auth_header) { 'invalid' }
  let(:has_header) { true }

  before do
    allow(mock_request).to receive(:headers).and_return(mock_auth_header)
    allow(mock_request).to receive(:has_header?).with('HTTP_AUTHORIZATION').and_return(has_header)
    allow(mock_request).to receive(:get_header).with('HTTP_AUTHORIZATION').and_return(mock_auth_header)
    allow(strategy).to receive(:request).and_return(mock_request)
  end

  subject { strategy.authenticate! }

  describe '#allow_always' do
    let(:strategy) { Volcanic::Authenticator::V1::Warden::AllowAlways.new(nil) }

    context 'success' do
      it { should eq :success }
    end

    context 'when token not exists' do
      let(:has_header) { false }
      it { should eq :success }
    end

    context 'when token is invalid' do
      let(:mock_auth_header) { invalid_auth_header }
      it { should eq :success }
    end
  end

  describe '#validate_token_always' do
    let(:strategy) { Volcanic::Authenticator::V1::Warden::ValidateTokenAlways.new(nil) }

    context 'success' do
      it { should eq :success }
    end

    context 'fail when token not exists' do
      let(:has_header) { false }
      it { should eq :failure }
    end

    context 'fail when token invalid' do
      let(:mock_auth_header) { invalid_auth_header }
      it { should eq :failure }
    end
  end

  describe 'validate_token_present' do
    let(:strategy) { Volcanic::Authenticator::V1::Warden::ValidatePresentToken.new(nil) }

    context 'success' do
      it { should eq :success }
    end

    context 'fail when token not exists' do
      let(:has_header) { false }
      it { should eq :success }
    end

    context 'fail when token invalid' do
      let(:mock_auth_header) { invalid_auth_header }
      it { should eq :failure }
    end
  end
end
