# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Permission, :vcr do
  before { Configuration.set }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:mock_name) { 'mock_permission_name' }
  let(:mock_description) { 'mock_permission_description' }
  let(:service_id) { 1 } # mock service id
  let(:permission_error) { Volcanic::Authenticator::V1::PermissionError }
  let(:new_permission) { permission.create(mock_name, service_id, mock_description) }

  describe 'Create' do
    context 'When missing name' do
      it { expect { permission.create(nil, service_id) }.to raise_error permission_error }
      it { expect { permission.create('', service_id) }.to raise_error permission_error }
    end

    context 'When missing service id' do
      it { expect { permission.create(mock_name, nil) }.to raise_error permission_error }
      it { expect { permission.create(mock_name, '') }.to raise_error permission_error }
    end

    context 'When duplicate name' do
      before { permission.create(mock_name, service_id, mock_description) }
      it { expect { permission.create(mock_name, service_id, mock_description) }.to raise_error permission_error }
    end

    context 'When success' do
      subject { new_permission }
      its(:name) { should eq mock_name }
      its(:id) { should eq 1 }
      its(:service_id) { should eq service_id }
      its(:subject_id) { should eq 2 }
      its(:description) { should eq mock_description }
    end
  end

  describe 'Find by given id' do
    context 'When missing id' do
      it { expect { permission.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { permission.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid id' do
      it { expect { permission.find_by_id('wrong_id') }.to raise_error permission_error }
    end

    context 'When success' do
      subject { permission.find_by_id(new_permission.id) }
      its(:name) { should eq new_permission.name }
      its(:id) { should eq new_permission.id }
      its(:description) { should eq new_permission.description }
      its(:service_id) { should eq new_permission.service_id }
      its(:subject_id) { should eq new_permission.subject_id }
      its(:active?) { should be true }
    end
  end

  describe 'Update' do
    let(:new_name) { 'new-permission' }

    context 'When required field is nil' do
      before { new_permission.name = nil }
      it { expect { new_permission.save }.to raise_error permission_error }
    end

    context 'When required field is empty' do
      before { new_permission.name = '' }
      it { expect { new_permission.save }.to raise_error permission_error }
    end

    context 'When changed name' do
      before do
        new_permission.name = new_name
        new_permission.save
      end
      subject { permission.find_by_id(new_permission.id) }
      its(:name) { should eq new_name }
    end

    context 'When update with existing name' do
      before { new_permission.name = new_name }
      it { expect { new_permission.save }.to raise_error permission_error }
    end
  end

  describe 'Delete' do
    let(:permission_id) { new_permission.id }
    context 'When deleted' do
      before { new_permission.delete }
      subject { permission.find_by_id(permission_id) }
      its(:active?) { should be false }
    end

    context 'when service already been deleted' do
      it { expect { new_permission.delete }.to raise_error permission_error }
    end

    context 'When invalid or non-exist id' do
      it { expect { permission.new(id: 'wrong-id').delete }.to raise_error permission_error }
      it { expect { permission.new(id: 123_456_789).delete }.to raise_error permission_error }
    end
  end
end
