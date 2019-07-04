# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Principal, :vcr do
  before { Configuration.set }
  let(:principal) { Volcanic::Authenticator::V1::Principal }
  let(:mock_name) { 'mock_principal_name' }
  let(:mock_dataset_id) { 10 }
  let(:principal_error) { Volcanic::Authenticator::V1::PrincipalError }
  let(:new_principal) { principal.create(mock_name, mock_dataset_id) }

  describe 'Create' do
    context 'When missing name' do
      it { expect { principal.create(nil, mock_dataset_id) }.to raise_error principal_error }
      it { expect { principal.create('', mock_dataset_id) }.to raise_error principal_error }
    end

    context 'When duplicate name' do
      before { principal.create(mock_name, mock_dataset_id) }
      it { expect { principal.create(mock_name, mock_dataset_id) }.to raise_error principal_error }
    end

    context 'When missing dataset_id' do
      it { expect { principal.create(mock_name, nil) }.to raise_error principal_error }
      it { expect { principal.create(mock_name, '') }.to raise_error principal_error }
    end

    context 'When success' do
      subject { principal.create(mock_name, mock_dataset_id) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
    end
  end

  # describe 'Find by given id' do
  #   subject { principal.find_by_id(new_principal.id) }
  #   context 'When missing id' do
  #     it { expect { principal.find_by_id(nil) }.to raise_error principal_error }
  #     it { expect { principal.find_by_id('') }.to raise_error principal_error }
  #   end
  #
  #   context 'When invalid id' do
  #     it { expect { principal.find_by_id('wrong_id') }.to raise_error principal_error }
  #   end
  #
  #   context 'Retrieve by id' do
  #     its(:name) { should_not be nil }
  #     its(:dataset_id) { should_not be nil }
  #     its(:id) { should_not be nil }
  #   end
  # end
  #
  # describe 'Update' do
  #   context 'When success update' do
  #     let(:attr) { { name: SecureRandom.hex(6) } }
  #     subject { principal.update(new_principal.id, attr) }
  #     it { should_not be raise_error }
  #   end
  # end
  #
  # describe 'Delete' do
  #   context 'When missing id' do
  #     it { expect { principal.delete(nil) }.to raise_error principal_error }
  #     it { expect { principal.delete('') }.to raise_error principal_error }
  #   end
  #
  #   context 'When invalid id' do
  #     it { expect { principal.delete('wrong_id') }.to raise_error principal_error }
  #   end
  #
  #   context 'When success delete' do
  #     subject { principal.delete(new_principal.id) }
  #     it { should_not be raise_error }
  #   end
  # end
end
