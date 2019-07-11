# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Role, :vcr do
  before { Configuration.set }
  let(:role) { Volcanic::Authenticator::V1::Role }
  let(:mock_name) { 'mock_name' }
  let(:mock_description) { 'mock_description' }
  let(:mock_service_id) { 1 }
  let(:mock_privilege_ids) { [1, 2] }
  let(:role_error) { Volcanic::Authenticator::V1::RoleError }
  let(:new_role) { role.create(mock_name, mock_service_id, mock_privilege_ids) }
  describe 'Create' do
    context 'When missing name' do
      it { expect { role.create(nil, mock_service_id) }.to raise_error role_error }
      it { expect { role.create('', mock_service_id) }.to raise_error role_error }
    end

    context 'When duplicate name' do
      before { role.create(mock_name, mock_service_id) }
      it { expect { role.create(mock_name, mock_service_id) }.to raise_error role_error }
    end

    context 'When creating' do
      subject { role.create(mock_name, mock_service_id) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:service_id) { should eq mock_service_id }
      its(:subject_id) { should eq 2 }
    end
  end

  describe 'Find' do
    context 'When find with default setting' do
      # this will return a default page: 1 and page_size: 10
      subject(:roles) { role.find }
      it { expect(roles[0].id).to eq 1 } # taking the first page
      it { expect(roles[0].name).to eq 'first-role' }
      it { expect(roles.count).to be <= 10 } # taking the page size to 10
    end

    context 'When find with specific page' do
      subject(:roles) { role.find(page: 2) }
      it { expect(roles[0].id).to eq 11 }
      it { expect(roles[0].name).to eq 'eleventh-role' }
      it { expect(roles.count).to be <= 10 }
    end

    context 'When find with specific page size' do
      subject(:roles) { role.find(page_size: 2) }
      it { expect(roles[0].id).to eq 1 }
      it { expect(roles[0].name).to eq 'first-role' }
      it { expect(roles.count).to be <= 2 }
    end

    context 'When find with page and page size' do
      subject(:roles) { role.find(page: 2, page_size: 3) }
      it { expect(roles[0].id).to eq 4 }
      it { expect(roles[0].name).to eq 'fourth-role' }
      it { expect(roles.count).to be <= 3 }
    end
  end

  describe 'Find by given id' do
    subject { role.find_by_id(new_role.id) }
    context 'When missing id' do
      it { expect { role.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { role.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid id' do
      it { expect { role.find_by_id('wrong_id') }.to raise_error role_error }
      it { expect { role.find_by_id(123_456_789) }.to raise_error role_error }
    end

    context 'When success' do
      its(:name) { should eq new_role.name }
      its(:id) { should eq new_role.id }
      its(:service_id) { should eq new_role.service_id }
      its(:subject_id) { should eq new_role.subject_id }
    end
  end

  describe 'Update' do
    let(:new_name) { 'new-role' }

    context 'When required field is nil' do
      before { new_role.name = nil }
      it { expect { new_role.save }.to raise_error role_error }
    end

    context 'When required field is empty' do
      before { new_role.name = nil }
      it { expect { new_role.save }.to raise_error role_error }
    end

    context 'When changed name' do
      before do
        new_role.name = new_name
        new_role.save
      end
      subject { role.find_by_id(new_role.id) }
      its(:name) { should eq new_name }
    end

    context 'When update with existing name' do
      before { new_role.name = new_name }
      it { expect { new_role.save }.to raise_error role_error }
    end
  end

  describe 'Delete' do
    let(:role_id) { new_role.id }
    context 'When deleted' do
      before { new_role.delete }
      it { expect { role.find_by_id(role_id) }.to raise_error role_error }
    end

    context 'when role already been deleted' do
      it { expect { new_role.delete }.to raise_error role_error }
    end

    context 'When invalid or non-exist id' do
      it { expect { role.new(id: 'wrong-id').delete }.to raise_error role_error }
      it { expect { role.new(id: 123_456_789).delete }.to raise_error role_error }
    end
  end
end
