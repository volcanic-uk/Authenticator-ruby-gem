# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Service, :vcr do
  before { Configuration.set }
  let(:service) { Volcanic::Authenticator::V1::Service }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }
  describe 'Service' do
    subject(:new_service) { service.create(mock_name) }
    describe 'Create' do
      context 'When missing name' do
        it { expect { service.create(nil) }.to raise_error Volcanic::Authenticator::V1::ServiceError }
        it { expect { service.create('') }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When duplicate name' do
        let(:duplicate_name) { SecureRandom.hex 6 }
        before { service.create(duplicate_name) }
        it { expect { service.create(duplicate_name) }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When creating' do
        it { is_expected.to be_an service }
        its(:name) { should be_a String }
        its(:id) { should be_an Integer }
      end
    end

    describe 'Read all' do
      subject { service.all }
      it { is_expected.to all(be_an(service)) }
    end

    describe 'Read by given id' do
      subject { service.find_by_id(new_service.id) }
      context 'When missing id' do
        it { expect { service.find_by_id(nil) }.to raise_error Volcanic::Authenticator::V1::ServiceError }
        it { expect { service.find_by_id('') }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When invalid id' do
        it { expect { service.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When success' do
        it { is_expected.to be_an service }
        its(:name) { should be_a String }
        its(:id) { should be_an Integer }
        its(:active?) { should be true }
      end
    end

    describe 'Update' do
      context 'When missing id' do
        it { expect { service.new(nil).save }.to raise_error Volcanic::Authenticator::V1::ServiceError }
        it { expect { service.new('').save }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When updated name' do
        let(:new_mock_name) { SecureRandom.hex(6) }
        before do
          new_service.name = new_mock_name
          new_service.save
        end
        it { should_not be raise_error }
        its(:name) { should be new_mock_name }
      end
    end

    describe 'Delete' do
      context 'When missing id' do
        it { expect { service.new(nil).delete }.to raise_error Volcanic::Authenticator::V1::ServiceError }
        it { expect { service.new('').delete }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When invalid id' do
        it { expect { service.new('wrong-id').delete }.to raise_error Volcanic::Authenticator::V1::ServiceError }
      end

      context 'When success' do
        subject { new_service.delete }
        it { should_not be raise_error }
      end
    end
  end
end
