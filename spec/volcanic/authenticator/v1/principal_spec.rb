# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Principal, :vcr do
  before { Configuration.set }
  let(:principal) { Volcanic::Authenticator::V1::Principal }
  let(:mock_name) { SecureRandom.hex 6 }
  describe 'Principal' do
    subject(:new_principal) { principal.create(mock_name, 1) }
    describe 'Create' do
      context 'When missing name' do
        it { expect { principal.create(nil, 1) }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
        it { expect { principal.create('', 1) }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'When duplicate name' do
        let(:duplicate_name) { SecureRandom.hex(6) }
        before { principal.create(duplicate_name, 1) }
        it { expect { principal.create(duplicate_name, 1) }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'When missing dataset_id' do
        it { expect { principal.create(SecureRandom.hex(6), nil) }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'When success' do
        it { is_expected.to be new_principal }
        its(:name) { should_not be nil }
        its(:dataset_id) { should_not be nil }
        its(:id) { should_not be nil }
      end
    end

    describe 'Get all' do
      subject { principal.all }
      it { should be_an_instance_of(Array) }
    end

    describe 'Find by given id' do
      subject { principal.find_by_id(new_principal.id) }
      context 'When missing id' do
        it { expect { principal.find_by_id(nil) }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
        it { expect { principal.find_by_id('') }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'When invalid id' do
        it { expect { principal.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'Retrieve by id' do
        its(:name) { should_not be nil }
        its(:dataset_id) { should_not be nil }
        its(:id) { should_not be nil }
      end
    end

    describe 'Update' do
      context 'When success update' do
        let(:attr) { { name: SecureRandom.hex(6) } }
        subject { principal.update(new_principal.id, attr) }
        it { should_not be raise_error }
      end
    end

    describe 'Delete' do
      context 'When missing id' do
        it { expect { principal.delete(nil) }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
        it { expect { principal.delete('') }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'When invalid id' do
        it { expect { principal.delete('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PrincipalError }
      end

      context 'When success delete' do
        subject { principal.delete(new_principal.id) }
        it { should_not be raise_error }
      end
    end
  end
end
