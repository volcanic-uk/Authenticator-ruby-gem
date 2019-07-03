# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Permission, :vcr do
  before { Configuration.set }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:service_id) { 1 } # mock service id
  let(:mock_description) { 'mock_description' }
  let(:new_permission) { permission.create(mock_name, service_id, mock_description) }

  describe 'Create' do
    subject { permission.create(mock_name, service_id, mock_description) }
    context 'When missing name' do
      it { expect { permission.create(nil, service_id) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      it { expect { permission.create('', service_id) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
    end

    context 'When missing service id' do
      it { expect { permission.create(mock_name, nil) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      it { expect { permission.create(mock_name, '') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
    end

    context 'When duplicate name' do
      let(:duplicate_name) { SecureRandom.hex(6) }
      before { permission.create(duplicate_name, service_id, mock_description) }
      it { expect { permission.create(duplicate_name, service_id, mock_description) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
    end

    context 'When success' do
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:service_id) { should_not be nil }
      its(:subject_id) { should_not be nil }
      its(:description) { should eq mock_description }
    end
  end

  describe 'Get all' do
    subject { permission.all }
    it { is_expected.to all(be_an(permission)) }
  end

  describe 'Find by given id' do
    context 'When missing id' do
      it { expect { permission.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { permission.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid id' do
      it { expect { permission.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
    end

    context 'When retrieved' do
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
    let(:permission_to_update) { permission.find_by_id(new_permission.id) }
    let(:new_mock_name) { SecureRandom.hex(6) }
    let(:new_mock_description) { 'new_mock_description' }
    before do
      permission_to_update.name = new_mock_name
      permission_to_update.description = new_mock_description
      permission_to_update.save
    end
    context 'When updated' do
      subject { permission.find_by_id(new_permission.id) }
      its(:name) { should_not be nil }
      its(:description) { should eq new_mock_description }
    end
  end

  describe 'Delete' do
    before { new_permission.delete }
    context 'When deleted' do
      subject { permission.find_by_id(new_permission.id) }
      its(:active?) { should be false }
    end
  end
end
