# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Service, :vcr do
  before { Configuration.set }
  let(:service) { Volcanic::Authenticator::V1::Service }
  let(:mock_name) { 'mock_name' }
  let(:mock_description) { 'mock_description' }
  let(:service_error) { Volcanic::Authenticator::V1::ServiceError }
  let(:new_service) { service.create(mock_name) }
  describe 'Create' do
    context 'When missing name' do
      it { expect { service.create(nil) }.to raise_error service_error }
      it { expect { service.create('') }.to raise_error service_error }
    end

    context 'When duplicate name' do
      before { service.create('service-a') }
      it { expect { service.create('service-a') }.to raise_error service_error }
    end

    context 'When creating' do
      subject { service.create(mock_name) }
      its(:name) { should eq mock_name }
      its(:id) { should eq 1 }
    end
  end

  describe 'Get all' do
    context 'When getting a default page size' do
      # this will return a default page: 1 and page_size: 10
      subject(:services) { service.all.count }
      it { should be <= 10 }
    end

    context 'When getting with only specific page size' do
      subject(:services) { service.all(page_size: 2) }
      it { expect(services.count).to eq 2 }
      it { expect(services[0].id).to eq 1 }
    end

    context 'When getting with a specific page and page size' do
      subject(:services) { service.all(page: 2, page_size: 3) }
      it { expect(services.count).to eq 3 }
      it { expect(services[0].id).to eq 4 }
    end

    context 'When getting with only specific page' do
      subject(:services) { service.all(page: 2) }
      it { expect(services.count).to be <= 10 }
      it { expect(services[0].id).to eq 11 }
    end
  end

  describe 'Find by given id' do
    subject { service.find_by_id(new_service.id) }
    context 'When missing id' do
      it { expect { service.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { service.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid id' do
      it { expect { service.find_by_id('wrong_id') }.to raise_error service_error }
    end

    context 'When success' do
      it { is_expected.to be_an service }
      its(:name) { should be_a String }
      its(:id) { should be_an Integer }
      its(:active?) { should be true }
    end
  end

  describe 'Update' do
    let(:new_name) { 'new-service' }

    context 'When required field is nil' do
      before { new_service.name = nil }
      it { expect { new_service.save }.to raise_error service_error }
    end

    context 'When required field is empty' do
      before { new_service.name = nil }
      it { expect { new_service.save }.to raise_error service_error }
    end

    context 'When changed name' do
      before do
        new_service.name = new_name
        new_service.save
      end
      subject { service.find_by_id(new_service.id) }
      its(:name) { should eq new_name }
    end

    context 'When update with existing name' do
      before { new_service.name = new_name }
      it { expect { new_service.save }.to raise_error service_error }
    end
  end

  describe 'Delete' do
    let(:service_id) { new_service.id }
    context 'When deleted' do
      before { new_service.delete }
      subject { service.find_by_id(service_id) }
      its(:active?) { should be false }
    end

    context 'when service already been deleted' do
      it { expect { new_service.delete }.to raise_error service_error }
    end

    context 'When invalid or non-exist id' do
      it { expect { service.new('wrong-id').delete }.to raise_error service_error }
      it { expect { service.new(123_456_789).delete }.to raise_error service_error }
    end
  end
end
