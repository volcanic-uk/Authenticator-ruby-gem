# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Group, :vcr do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:mock_name) { 'mock_name' }
  let(:mock_description) { 'mock_description' }
  let(:mock_permission_id) { [1, 2] }
  let(:group_error) { Volcanic::Authenticator::V1::GroupError }
  let(:new_group) { group.create(mock_name, mock_description, mock_permission_id) }

  describe 'Create' do
    context 'When missing name' do
      it { expect { group.create(nil, mock_description) }.to raise_error group_error }
      it { expect { group.create('', mock_description) }.to raise_error group_error }
    end

    context 'When duplicate name' do
      before { group.create(mock_name, mock_description) }
      it { expect { group.create(mock_name, mock_description) }.to raise_error group_error }
    end

    context 'When invalid permission_id' do
      it { expect { group.create(mock_name, mock_description, 'wrong_id') }.to raise_error group_error }
      it { expect { group.create(mock_name, mock_description, 123_456_789) }.to raise_error group_error }
    end

    context 'When success' do
      subject { new_group }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
    end
  end

  describe 'Find' do
    context 'When find with default setting' do
      # this will return a default page: 1 and page_size: 10
      subject(:groups) { group.find }
      it { expect(groups[0].id).to eq 1 } # taking the first page
      it { expect(groups[0].name).to eq 'first-group' }
      it { expect(groups.count).to be <= 10 } # taking the page size to 10
    end

    context 'When find with specific page' do
      subject(:groups) { group.find(page: 2) }
      it { expect(groups[0].id).to eq 11 }
      it { expect(groups[0].name).to eq 'eleventh-group' }
      it { expect(groups.count).to be <= 10 }
    end

    context 'When find with specific page size' do
      subject(:groups) { group.find(page_size: 2) }
      it { expect(groups[0].id).to eq 1 }
      it { expect(groups[0].name).to eq 'first-group' }
      it { expect(groups.count).to be <= 2 }
    end

    context 'When find with page and page size' do
      subject(:groups) { group.find(page: 2, page_size: 3) }
      it { expect(groups[0].id).to eq 4 }
      it { expect(groups[0].name).to eq 'fourth-group' }
      it { expect(groups.count).to be <= 3 }
    end

    context 'When find with key_name' do
      subject(:groups) { group.find(key_name: 'gro') }
      it { expect(groups[0].name).to eq 'first-group' }
      it { expect(groups[1].name).to eq 'second-group' }
      it { expect(groups[2].name).to eq 'third-group' }
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
      its(:id) { should eq new_group.id }
      its(:name) { should eq new_group.name }
      its(:subject_id) { should eq new_group.subject_id }
      its(:active?) { should eq true }
    end
  end

  describe 'Update' do
    let(:new_name) { 'new-group' }
    let(:new_description) { 'new-group-description' }

    context 'When required field is nil' do
      before { new_group.name = nil }
      it { expect { new_group.save }.to raise_error group_error }
    end

    context 'When required field is empty' do
      before { new_group.name = '' }
      it { expect { new_group.save }.to raise_error group_error }
    end

    context 'When changed name' do
      before do
        new_group.name = new_name
        new_group.save
      end
      subject { group.find_by_id(new_group.id) }
      its(:name) { should eq new_name }
    end

    context 'When changed description' do
      before do
        new_group.description = new_description
        new_group.save
      end
      subject { group.find_by_id(new_group.id) }
      its(:description) { should eq new_description }
    end

    context 'When update with existing name' do
      before { new_group.name = new_name }
      it { expect { new_group.save }.to raise_error group_error }
    end
  end

  describe 'Delete' do
    let(:group_id) { new_group.id }
    context 'When deleted' do
      before { new_group.delete }
      subject { group.find_by_id(group_id) }
      its(:active?) { should be false }
    end

    context 'when group already been deleted' do
      it { expect { new_group.delete }.to raise_error group_error }
    end

    context 'When invalid or non-exist id' do
      it { expect { group.new(id: 'wrong-id').delete }.to raise_error group_error }
      it { expect { group.new(id: 123_456_789).delete }.to raise_error group_error }
    end
  end
end
