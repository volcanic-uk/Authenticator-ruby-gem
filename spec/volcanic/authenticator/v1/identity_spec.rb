# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Identity do
  before { Configure.set }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_dataset_id) { 1 }
  let(:principal) { Principal.create(mock_name, mock_dataset_id) }

  describe 'Create' do
  end

  describe 'Delete' do
  end
end
