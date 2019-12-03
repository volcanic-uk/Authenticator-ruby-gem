# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Warden, :vcr do
  before { Configuration.set }
  let(:mock_request) { double 'request' }
  let(:allow_always_strategy) { Volcanic::Authenticator::V1::Warden::AllowAlways.new(nil) }
  let(:validate_token_always_strategy) { Volcanic::Authenticator::V1::Warden::ValidateTokenAlways.new(nil) }
  let(:validate_token_present_strategy) { Volcanic::Authenticator::V1::Warden::ValidatePresentToken.new(nil) }
  let(:tokens) { JSON.parse(Configuration.mock_tokens) }
  let(:mock_token_base64) { tokens['token'] }
  let(:mock_auth_header) { "Bearer #{mock_token_base64}" }
  let(:invalid_auth_header) { 'invalid' }

  before do
    allow(mock_request).to receive(:headers).and_return(mock_auth_header)
    allow(mock_request).to receive(:has_header?).with('HTTP_AUTHORIZATION').and_return(true)
    allow(mock_request).to receive(:get_header).with('HTTP_AUTHORIZATION').and_return(mock_auth_header)
  end

  describe '#allow_always' do
    before { allow(allow_always_strategy).to receive(:request).and_return(mock_request) }
    subject { allow_always_strategy.authenticate! }

    context 'success' do
      it { should eq :success }
    end

    context 'when token not exists' do
      before { allow(mock_request).to receive(:has_header?).with('HTTP_AUTHORIZATION').and_return(false) }
      it { should eq :success }
    end

    context 'when token is invalid' do
      before { allow(mock_request).to receive(:get_header).with('HTTP_AUTHORIZATION').and_return(invalid_auth_header) }
      it { should eq :success }
    end
  end

  describe '#validate_token_always' do
    before { allow(validate_token_always_strategy).to receive(:request).and_return(mock_request) }
    subject { validate_token_always_strategy.authenticate! }

    context 'success' do
      it { should eq :success }
    end

    context 'fail when token not exists' do
      before { allow(mock_request).to receive(:has_header?).with('HTTP_AUTHORIZATION').and_return(false) }
      it { should eq :failure }
    end

    context 'fail when token invalid' do
      before { allow(mock_request).to receive(:get_header).with('HTTP_AUTHORIZATION').and_return(invalid_auth_header) }
      it { should eq :failure }
    end
  end

  describe 'validate_token_present' do
    before { allow(validate_token_present_strategy).to receive(:request).and_return(mock_request) }
    subject { validate_token_present_strategy.authenticate! }

    context 'success' do
      it { should eq :success }
    end

    context 'fail when token not exists' do
      before { allow(mock_request).to receive(:has_header?).with('HTTP_AUTHORIZATION').and_return(false) }
      it { should eq :success }
    end

    context 'fail when token invalid' do
      before { allow(mock_request).to receive(:get_header).with('HTTP_AUTHORIZATION').and_return(invalid_auth_header) }
      it { should eq :failure }
    end
  end
end
