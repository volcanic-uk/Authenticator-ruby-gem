# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Service, :vcr do
  before { Configuration.set }
  let(:service) { Volcanic::Authenticator::V1::Service }
  let(:mock_name) { 'mock_name' }
  let(:mock_description) { 'mock_description' }
  let(:service_error) { Volcanic::Authenticator::V1::ServiceError }
  let(:new_service) { service.create(mock_name) }
  describe '.create' do
    context 'when missing name' do
      it { expect { service.create(nil) }.to raise_error service_error }
      it { expect { service.create('') }.to raise_error service_error }
    end

    context 'when duplicate name' do
      before { service.create('service-a') }
      it { expect { service.create('service-a') }.to raise_error service_error }
    end

    context 'when creating' do
      subject { service.create(mock_name) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:subject_id) { should eq '2' }
    end
  end

  describe '.find' do
    context 'when find by id' do
      subject { service.find_by_id(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:subject_id) { should eq '2' }
      # its(:active?) { should eq true }
    end

    context 'when find with specific page' do
      subject(:services) { service.find(page: 2) }
      it { expect(services[0].id).to eq 11 }
      it { expect(services.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:services) { service.find(page_size: 2) }
      it { expect(services[0].id).to eq 1 }
      it { expect(services.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:services) { service.find(page: 2, page_size: 3) }
      it { expect(services[0].id).to eq 4 }
      it { expect(services.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:services) { service.find(query: 'vol') }
      it { expect(services[0].name).to eq 'volcanic' }
      it { expect(services[1].name).to eq 'vol' }
    end

    context 'when find with pagination' do
      subject(:services) { service.find }
      it { expect(services.page).to eq 1 }
      it { expect(services.page_size).to eq 10 }
      it { expect(services.row_count).to eq 20 }
      it { expect(services.page_count).to eq 2 }
    end

    context 'when find with sort and order' do
      subject(:services) { service.find(sort: 'id', order: 'desc') }
      it { expect(services[0].id).to eq 20 }
      it { expect(services[1].id).to eq 19 }
      it { expect(services[2].id).to eq 18 }
    end
  end

  describe '.first' do
    # TODO: need to be remove
  end

  describe '.last' do
    # TODO: need to be remove
  end

  describe '.count' do
    # TODO: need to be remove
  end

  describe '.save' do
    let(:new_name) { 'new-service' }
    let(:new_description) { 'new-service-description' }

    context 'when required field is nil' do
      before { new_service.name = nil }
      it { expect { new_service.save }.to raise_error service_error }
    end

    context 'when required field is empty' do
      before { new_service.name = '' }
      it { expect { new_service.save }.to raise_error service_error }
    end

    context 'when changed name' do
      before do
        new_service.name = new_name
        new_service.save
      end
      subject { service.find_by_id(new_service.id) }
      its(:name) { should eq new_name }
    end

    context 'when update with existing name' do
      before { new_service.name = new_name }
      it { expect { new_service.save }.to raise_error service_error }
    end
  end

  describe '.delete' do
    let(:service_id) { new_service.id }
    context 'when deleted' do
      # TODO: write some test here
    end

    context 'when service already been deleted' do
      it { expect { new_service.delete }.to raise_error service_error }
    end

    context 'when invalid or non-exist id' do
      it { expect { service.new(id: 'wrong-id').delete }.to raise_error service_error }
      it { expect { service.new(id: 123_456_789).delete }.to raise_error service_error }
    end
  end
end
