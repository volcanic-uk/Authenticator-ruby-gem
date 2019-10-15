# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Permission, :vcr do
  before { Configuration.set }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:mock_name) { 'mock_permission_name' }
  let(:mock_description) { 'mock_permission_description' }
  let(:service_id) { 1 } # mock service id
  let(:permission_error) { Volcanic::Authenticator::V1::PermissionError }
  let(:new_permission) { permission.create(mock_name, service_id, mock_description) }

  describe '#create' do
    context 'when missing name' do
      it { expect { permission.create(nil, service_id) }.to raise_error permission_error }
      it { expect { permission.create('', service_id) }.to raise_error permission_error }
    end

    context 'when missing service id' do
      it { expect { permission.create(mock_name, nil) }.to raise_error permission_error }
      it { expect { permission.create(mock_name, '') }.to raise_error permission_error }
    end

    context 'when duplicate name' do
      before { permission.create(mock_name, service_id, mock_description) }
      it { expect { permission.create(mock_name, service_id, mock_description) }.to raise_error permission_error }
    end

    context 'when success' do
      subject { new_permission }
      its(:name) { should eq mock_name }
      its(:id) { should eq 1 }
      its(:service_id) { should eq service_id }
      its(:subject_id) { should eq 2 }
      its(:description) { should eq mock_description }
    end
  end

  describe '#find' do
    context 'when find by id' do
      subject { permission.find_by_id(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:description) { should eq mock_description }
      its(:subject_id) { should eq 1 }
      its(:service_id) { should eq 1 }
    end

    context 'when find with specific page' do
      subject(:permissions) { permission.find(page: 2) }
      it { expect(permissions[0].id).to eq 11 }
      it { expect(permissions[0].name).to eq 'permission_11' }
      it { expect(permissions.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:permissions) { permission.find(page_size: 2) }
      it { expect(permissions[0].id).to eq 1 }
      it { expect(permissions[0].name).to eq 'permission_1' }
      it { expect(permissions.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:permissions) { permission.find(page: 2, page_size: 3) }
      it { expect(permissions[0].id).to eq 4 }
      it { expect(permissions[0].name).to eq 'permission_4' }
      it { expect(permissions.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:permissions) { permission.find(query: 'vol') }
      it { expect(permissions[0].name).to eq 'permission_volcanic' }
      it { expect(permissions[1].name).to eq 'perm_vol' }
    end

    context 'when find with pagination' do
      subject { permission.find }
      its(:page) { should eq 1 }
      its(:page_size) { should eq 10 }
      its(:row_count) { should eq 14 }
      its(:page_count) { should eq 2 }
    end
  end

  describe '#save' do
    let(:new_name) { 'new-permission' }
    let(:new_description) { 'new-description' }
    subject(:permission_save) { new_permission }

    context 'when name nil' do
      before { permission_save.name = nil }
      it { expect { permission_save.save }.to raise_error permission_error }
    end

    context 'when name is empty' do
      before { permission_save.name = '' }
      it { expect { permission_save.save }.to raise_error permission_error }
    end

    context 'when name exists' do
      before { permission_save.name = 'duplicate-name' }
      it { expect { permission_save.save }.to raise_error permission_error }
    end

    context 'when updating name and description' do
      before do
        permission_save.name = new_name
        permission_save.name = new_name
        permission_save.save
      end
      subject { permission.find_by_id(permission_save.id) }
      its(:name) { should eq new_name }
      its(:description) { should eq new_description }
    end
  end

  describe '#delete' do
    context 'when deleted' do
      before { permission.find_by_id(1).delete }
      subject { permission.find_by_id(1) }
      its(:active?) { should eq false }
    end

    context 'when service already been deleted' do
      before { new_permission.delete }
      it { expect { new_permission.delete }.to raise_error permission_error }
    end
  end
end
