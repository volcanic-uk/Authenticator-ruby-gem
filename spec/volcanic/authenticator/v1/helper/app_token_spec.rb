# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Volcanic::Authenticator::V1::AppToken do
  before do
    allow(described_class).to \
      receive(:perform_post_and_parse)
      .and_return({ 'token' => token })

    allow(Time).to receive(:now).and_return(current_time)
  end

  let(:token) { JWT.encode(token_payload, nil, 'none') }
  let(:token_payload) { { exp: token_expiry, sub: 'user://foo/bar' } }
  let(:token_expiry) { 5 }
  let(:current_time) { token_expiry - 2 }

  subject(:fetched_token) { described_class.fetch_and_request }

  context 'when the token is not cached' do
    it 'obtains the token and caches for next time' do
      expect(described_class).to \
        receive(:perform_post_and_parse)
        .and_return({ 'token' => token })
        .once

      described_class.fetch_and_request
      described_class.fetch_and_request
    end
  end

  context 'when the token has been cached' do
    before do
      described_class.fetch_and_request
    end

    context 'and the token has expired' do
      let(:current_time) { token_expiry + 5 }

      it 'retrieves a new token' do
        expect(described_class).to \
          receive(:perform_post_and_parse)
          .and_return({ 'token' => token })
          .once # a second time

        described_class.fetch_and_request
      end
    end

    context 'and the token is removed from the cache' do
      before { described_class.invalidate_cache! }

      it 'retrieves a new token' do
        expect(described_class).to \
          receive(:perform_post_and_parse)
          .and_return({ 'token' => token })
          .once # a second time

        described_class.fetch_and_request
      end
    end
  end
end
