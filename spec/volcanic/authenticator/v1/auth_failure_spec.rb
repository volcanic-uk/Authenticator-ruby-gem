# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::Warden::AuthFailure do
  let(:failure_app) { Volcanic::Authenticator::Warden::AuthFailure }
  let(:env) {}

  subject { failure_app.call(env) }

  describe 'default' do
    let(:env) { { 'warden.options': {}, 'warden': nil } }
    it 'returning default rack' do
      should eq [401, { 'Context-Type' => 'application/json' }, ['{"message":"unauthorized!"}']]
    end
  end

  describe 'custom' do
    context 'when enable redirect' do
      context 'with specific path' do
        let(:redirect_path) { '/' }
        let(:env) { { 'warden.options' => { redirect_on_fail: redirect_path }, 'warden': nil } }
        it { should eq [302, { 'location' => redirect_path }, [nil]] }
      end

      context 'with nil path' do
        let(:redirect_path) { nil }
        let(:env) { { 'warden.options' => { redirect_on_fail: redirect_path }, 'warden': nil } }
        it { should eq [401, { 'Context-Type' => 'application/json' }, ['{"message":"unauthorized!"}']] }
      end
    end

    context 'when customize all' do
      let(:mock_status) { 404 }
      let(:mock_header) { { 'Context-Type' => 'mock_header' } }
      let(:mock_body) { { message: 'mock_message' } }
      subject { failure_app.new(status: mock_status, headers: mock_header, body: mock_body).call(env) }
      it { should eq [mock_status, mock_header, [mock_body.to_json]] }

      context 'when not providing status' do
        let(:mock_status) { nil }
        it { should eq [401, mock_header, [mock_body.to_json]] }
      end

      context 'when not providing headers' do
        let(:mock_header) { nil }
        it { should eq [mock_status, { 'Context-Type' => 'application/json' }, [mock_body.to_json]] }
      end

      context 'when not providing body' do
        let(:mock_body) { nil }
        it { should eq [mock_status, mock_header, ['{"message":"unauthorized!"}']] }
      end
    end
  end
end
