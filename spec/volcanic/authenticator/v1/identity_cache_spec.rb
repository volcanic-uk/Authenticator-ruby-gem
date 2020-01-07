# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::IdentityCache, :vcr do
  let(:cache) { Volcanic::Cache::Cache }
  let(:identity_cache) { Volcanic::Authenticator::V1::IdentityCache }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:id) { 1 } # mock id
  let(:name) { 'mock_name' } # mock name
  let(:secret) { 'mock_secret' } # mock secret
  let(:dataset_id) { 'mock_id' } # mock dataset_id
  let(:exp) { (Time.now + 1.minutes).to_i } # mock token expire
  let(:token_instance) { double 'token' } # mock token object
  let(:instance) {}
  let(:result_values) { [token_instance, false] }

  before(:context) { Volcanic::Cache::Cache._reset_instance } # reset cache for each context
  before do
    allow(token_instance).to receive('exp').and_return(exp)
    allow(instance).to receive('request_token').and_return(*result_values)
  end

  describe '#login' do
    context 'when caching' do
      let(:instance) { identity_cache.new(name: name, secret: secret, dataset_id: dataset_id) }
      it('return token and cached') do
        expect(instance.login).to eq result_values[0] # request new
        expect(cache.key?(gen_key(name, secret, dataset_id))).to eq true
        expect(instance.login).to eq result_values[0] # fetch from cache
      end
    end

    context 'when not caching' do
      let(:instance) { identity.new(name: name, secret: secret, dataset_id: dataset_id) } # result is not cached
      it('return the exact result') do
        expect(instance.login).to eq result_values[0] # return the 1st result
        expect(instance.login).to eq result_values[1] # return the 2nd result
      end
    end
  end

  describe '#token' do
    context 'when caching' do
      let(:instance) { identity_cache.new(id: id) }
      it('return token and cached') do
        expect(instance.token).to eq result_values[0]
        expect(cache.key?(gen_key(id))).to eq true
        expect(instance.token).to eq result_values[0] # fetch from cache
      end
    end

    context 'when not caching' do
      let(:instance) { identity.new(id: id) } # result is not cached
      it('return the exact result') do
        expect(instance.login).to eq result_values[0] # return the 1st result
        expect(instance.login).to eq result_values[1] # return the 2nd result
      end
    end
  end

  private

  # Volcanic::Cache::Cache use key to store value.
  # This method use when checking the key exist in cache or not.
  def gen_key(*opts)
    opts.compact.flatten.join(':')
  end
end
