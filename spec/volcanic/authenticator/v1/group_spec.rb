# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Group, :vcr do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:mock_permission_id) { 1 }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }
  let(:group_error) { Volcanic::Authenticator::V1::GroupError }
  let(:new_group) { group.create(mock_name, mock_description, mock_permission_id) }

  describe 'Create' do
    subject { group.create(mock_name, mock_description, mock_permission_id) }
    context 'When missing name' do
      it { expect { group.create(nil, mock_description) }.to raise_error group_error }
      it { expect { group.create('', mock_description) }.to raise_error group_error }
    end

    context 'When duplicate name' do
      let(:duplicate_name) { SecureRandom.hex 6 }
      before { group.create(duplicate_name, mock_description) }
      it { expect { group.create(duplicate_name, mock_description) }.to raise_error group_error }
    end

    context 'When invalid permission_id' do
      it { expect { group.create(mock_name, mock_description, ['wrong_id']) }.to raise_error group_error }
    end

    context 'When creating' do
      its(:id) { should_not be nil }
      its(:name) { should_not be nil }
    end
  end

  describe 'Get all' do
    context 'When default page size' do
      subject { group.all.count }
      it { should be <= 10 }
    end

    context 'When custom page size' do
      subject { group.all(page_size: 2).count }
      it { should be <= 2 }
    end

    context 'When custom page' do
      subject { group.all(page: 2, page_size: 2).count }
      it { should be <= 2 }
    end
  end

  describe 'Find by given id' do
    context 'When missing id' do
      it { expect { group.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { group.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid id' do
      it { expect { group.find_by_id('wrong_id') }.to raise_error group_error }
    end

    context 'When retrieve by id' do
      subject { group.find_by_id(new_group.id) }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      # its(:subject_id) { should_not be nil } # auth service bug
      its(:active?) { should eq true }
    end
  end

  describe 'Update' do
    let(:group_to_update) { group.find_by_id(new_group.id) }
    let(:new_mock_name) { SecureRandom.hex(6) }
    let(:new_mock_description) { 'new_mock_description' }
    before do
      group_to_update.name = new_mock_name
      group_to_update.description = new_mock_description
      group_to_update.save
    end
    context 'When updated' do
      subject { group.find_by_id(new_group.id) }
      its(:name) { should_not be nil }
      its(:description) { should eq new_mock_description }
    end
  end

  describe 'Delete' do
    before { new_group.delete }
    context 'When deleted' do
      subject { group.find_by_id(new_group.id) }
      its(:active?) { should eq false }
    end
  end
end
