# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::TokenCache, :vcr do
  before { Configuration.set }
  let(:token) { Volcanic::Authenticator::V1::TokenCache }
  let(:cache) { Volcanic::Cache::Cache.instance }
  let(:jsons) { JSON.parse(Configuration.mock_tokens) }
  let(:mock_token_key) { jsons['token'] }
  let(:remote_validate_error) { Volcanic::Authenticator::V1::AuthorizationError }

  before(:context) { Volcanic::Cache::Cache._reset_instance } # reset cache
  subject(:instance) { token.new(mock_token_key) }

  describe '#remote_validate' do
    context 'when validation result is not cached' do
      before { allow(instance).to receive(:perform_post_and_parse).and_return(true) }

      it('return the value and save to cache') do
        expect(cache.key?(instance.to_base64)).to be false # is not cached
        expect(instance.remote_validate).to be true
        expect(cache.key?(instance.to_base64)).to be true # is cached
      end
    end

    context 'when validation result is cached' do
      before do
        allow(instance).to receive(:perform_post_and_parse).once.and_return(true)
        allow(instance).to receive(:perform_post_and_parse).once.and_raise(remote_validate_error)
        instance.remote_validate
      end

      it('return the cached value') do
        expect(instance.remote_validate).to be true
      end
    end
  end

  describe '#revoke!' do
    before do
      allow(instance).to receive(:perform_post_and_parse).and_return(true)
      instance.remote_validate # caching result
    end

    it 'when value is in cache' do
      expect(cache.key?(instance.to_base64)).to be true # value cached
      instance.revoke!
      expect(cache.key?(instance.to_base64)).to be false # value removed
    end
  end
end
