# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::TokenCache, :vcr do
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:token_cache) { Volcanic::Authenticator::V1::TokenCache }
  let(:cache) { Volcanic::Cache::Cache.instance }
  let(:jsons) { JSON.parse(Configuration.mock_tokens) }
  let(:mock_token_key) { jsons['token'] }
  let(:validate_success) { true }
  let(:validate_fail) { false }
  let(:remote_validate_error) { Volcanic::Authenticator::V1::AuthorizationError }

  after(:context) { Volcanic::Cache::Cache._reset_instance } # reset cache
  let(:instance) { token_cache.new(mock_token_key) }

  describe '#remote_validate' do
    context 'when is not cached yet' do
      before { allow(instance).to receive(:perform_post_and_parse).and_return(validate_success) }

      it('return success and cached') do
        expect(cache.key?(instance.to_base64)).to be false # is not cached
        expect(instance.remote_validate).to be validate_success
        expect(cache.key?(instance.to_base64)).to be true # is cached
      end
    end

    context 'when is already cached' do
      before do
        allow(instance).to receive(:perform_post_and_parse).and_return(validate_success)
        allow(instance).to receive(:perform_post_and_parse).and_raise(remote_validate_error)
        instance.remote_validate # here where the cache happened
      end

      it('return success and cached') do
        expect(cache.key?(instance.to_base64)).to be true
        expect(instance.remote_validate).to be validate_success # instead of returning validation error is return success
      end
    end

    context 'when not caching' do
      let(:instance) { token.new(mock_token_key) } # using token (class) instead of token_cache
      before do
        allow(instance).to receive(:perform_post_and_parse).and_return(validate_success)
        allow(instance).to receive(:perform_post_and_parse).and_raise(remote_validate_error)
        instance.remote_validate # here where the cache happened
      end

      it('return success and cached') do
        expect(instance.remote_validate).to be validate_fail # return 2nd result
      end
    end
  end

  describe '#revoke!' do
    before do
      allow(instance).to receive(:perform_post_and_parse).and_return(validate_success)
      instance.remote_validate
    end

    it 'when value is in cache' do
      expect(cache.key?(instance.to_base64)).to be true # value cached
      instance.revoke!
      expect(cache.key?(instance.to_base64)).to be false # value removed
    end
  end
end
