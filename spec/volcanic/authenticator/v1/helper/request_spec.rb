# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Volcanic::Authenticator::V1::Request do
  subject(:klazz) { Class.new { include Volcanic::Authenticator::V1::Request }.new }

  describe '#perform_request_and_parse' do
    before do
      Volcanic::Authenticator::V1::AppToken.invalidate_cache!
      allow(Time).to receive(:now).and_return(5)
      allow(HTTParty).to receive(:post).and_return(token_response)

      allow(HTTParty).to receive(:get).and_return(response)
      allow(response).to receive(:success?) { response.code == 200 }
    end

    let(:token_response) do
      double(:token_resp, code: 200, success?: true, body: { response: { token: token } }.to_json)
    end
    let(:token) { JWT.encode(token_payload, nil, 'none') }
    let(:token_payload) { { exp: 10, sub: 'user://foo/bar' } }
    let(:response) { double(:resp, code: response_code, body: response_body) }
    let(:response_code) { 200 }
    let(:response_body) { '{ "response": "success" }' }
    let(:exception) { double(:exception) }
    let(:url) { 'http://mytest.com' }

    context 'when an auth token is not provided' do
      subject { klazz.perform_request_and_parse(:get, exception, url) }

      it 'returns the response value' do
        expect(subject).to eq 'success'
      end

      context 'and the response is forbidden' do
        let(:response_code) { 403 }
        it 'raises an authorization exception' do
          expect { subject }.to raise_error(Volcanic::Authenticator::V1::AuthorizationError)
        end
      end

      context 'and the response is unauthenticated' do
        let(:response_code) { 401 }
        it 'raises an authentication exception' do
          expect { subject }.to raise_error(Volcanic::Authenticator::V1::AuthenticationError)
        end

        it 'authenticates 3 times before failing' do
          expect(HTTParty).to receive(:post).exactly(3).times.and_return(token_response)
          expect { subject }.to raise_error(Volcanic::Authenticator::V1::AuthenticationError)
        end
      end
    end
  end
end
