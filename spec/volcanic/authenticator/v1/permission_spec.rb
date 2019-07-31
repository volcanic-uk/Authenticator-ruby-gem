# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Permission, :vcr do
  before { Configuration.set }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:mock_name) { 'mock_permission_name' }
  let(:mock_description) { 'mock_permission_description' }
  let(:service_id) { 1 } # mock service id
  let(:permission_error) { Volcanic::Authenticator::V1::PermissionError }
  let(:new_permission) { permission.create(mock_name, service_id, mock_description) }

  describe '.create' do
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

  describe '.find' do
    context 'when find by id' do
      subject { permission.find(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:description) { should eq mock_description }
      its(:subject_id) { should eq 1 }
      its(:service_id) { should eq 1 }
      its(:active?) { should eq true }
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
      subject(:permissions) { permission.find(pagination: true) }
      let(:mock_pagination) { { page: 1, pageSize: 10, rowCount: 14, pageCount: 2 } }
      it { expect(permissions[:pagination]). to eq mock_pagination }
      it { expect(permissions[:data].count). to eq 10 }
    end
  end

  describe '.first' do
    context 'when received first object' do
      subject { permission.first }
      its(:id) { should eq 1 }
      its(:name) { should eq 'permission_1' }
    end
  end

  describe '.last' do
    context 'when received last object' do
      subject { permission.last }
      its(:id) { should eq 26 }
      its(:name) { should eq 'permission_26' }
    end
  end

  describe '.count' do
    subject { permission.count }
    it { should eq 26 }
  end

  # describe 'Find' do
  #   context 'When find with default setting' do
  #     # this will return a default page: 1 and page_size: 10
  #     subject(:permissions) { permission.find }
  #     it { expect(permissions[0].id).to eq 1 } # taking the first page
  #     it { expect(permissions[0].name).to eq 'first-permission' }
  #     it { expect(permissions.count).to be <= 10 } # taking the page size to 10
  #   end
  #
  #   context 'When find with specific page' do
  #     subject(:permissions) { permission.find(page: 2) }
  #     it { expect(permissions[0].id).to eq 11 }
  #     it { expect(permissions[0].name).to eq 'eleventh-permission' }
  #     it { expect(permissions.count).to be <= 10 }
  #   end
  #
  #   context 'When find with specific page size' do
  #     subject(:permissions) { permission.find(page_size: 2) }
  #     it { expect(permissions[0].id).to eq 1 }
  #     it { expect(permissions[0].name).to eq 'first-permission' }
  #     it { expect(permissions.count).to be <= 2 }
  #   end
  #
  #   context 'When find with page and page size' do
  #     subject(:permissions) { permission.find(page: 2, page_size: 3) }
  #     it { expect(permissions[0].id).to eq 4 }
  #     it { expect(permissions[0].name).to eq 'fourth-permission' }
  #     it { expect(permissions.count).to be <= 3 }
  #   end
  # end

  # describe 'Find by given id' do
  #   context 'When missing id' do
  #     it { expect { permission.find_by_id(nil) }.to raise_error ArgumentError }
  #     it { expect { permission.find_by_id('') }.to raise_error ArgumentError }
  #   end
  #
  #   context 'When invalid id' do
  #     it { expect { permission.find_by_id('wrong_id') }.to raise_error permission_error }
  #   end
  #
  #   context 'When success' do
  #     subject { permission.find_by_id(new_permission.id) }
  #     its(:name) { should eq new_permission.name }
  #     its(:id) { should eq new_permission.id }
  #     its(:description) { should eq new_permission.description }
  #     its(:service_id) { should eq new_permission.service_id }
  #     its(:subject_id) { should eq new_permission.subject_id }
  #     its(:active?) { should be true }
  #   end
  # end

  describe '.save' do
    let(:new_name) { 'new-permission' }

    context 'when required field is nil' do
      before { new_permission.name = nil }
      it { expect { new_permission.save }.to raise_error permission_error }
    end

    context 'when required field is empty' do
      before { new_permission.name = '' }
      it { expect { new_permission.save }.to raise_error permission_error }
    end

    context 'when changed name' do
      before do
        new_permission.name = new_name
        new_permission.save
      end
      subject { permission.find(new_permission.id) }
      its(:name) { should eq new_name }
    end

    context 'when update with existing name' do
      before { permission.create('duplicate-name', service_id, mock_description) }
      before { new_permission.name = 'duplicate-name' }
      it { expect { new_permission.save }.to raise_error permission_error }
    end
  end

  describe '.delete' do
    context 'when deleted' do
      before { permission.find(1).delete }
      subject { permission.find(1) }
      its(:active?) { should eq false }
    end

    context 'when service already been deleted' do
      before { new_permission.delete }
      it { expect { new_permission.delete }.to raise_error permission_error }
    end

    context 'when invalid or non-exist id' do
      # it { expect { permission.new(id: 'wrong-id').delete }.to raise_error permission_error }
      it { expect { permission.new(id: 123_456_789).delete }.to raise_error permission_error }
    end
  end
end
