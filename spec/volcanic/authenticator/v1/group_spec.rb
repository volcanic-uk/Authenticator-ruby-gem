# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Group, :vcr do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:mock_name) { 'mock_name' }
  let(:mock_description) { 'mock_description' }
  let(:mock_permission_id) { [1, 2] }
  let(:group_error) { Volcanic::Authenticator::V1::GroupError }
  let(:new_group) { group.create(mock_name, mock_description, mock_permission_id) }

  describe '#create' do
    context 'when missing name' do
      it { expect { group.create(nil, mock_description) }.to raise_error group_error }
      it { expect { group.create('', mock_description) }.to raise_error group_error }
    end

    context 'when duplicate name' do
      before { group.create(mock_name, mock_description) }
      it { expect { group.create(mock_name, mock_description) }.to raise_error group_error }
    end

    context 'when invalid permission_id' do
      it { expect { group.create(mock_name, mock_description, 'wrong_id') }.to raise_error group_error }
      it { expect { group.create(mock_name, mock_description, 123_456_789) }.to raise_error group_error }
    end

    context 'when success' do
      subject { new_group }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
    end
  end

  describe '#find' do
    context 'when find by id' do
      subject { group.find_by_id(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:description) { should eq mock_description }
    end

    context 'when find by name' do
      subject { group.find_by_name('group') }
      its(:id) { should eq 1 }
      its(:name) { should eq 'group' }
      its(:description) { should eq mock_description }
    end

    context 'when find with specific page' do
      subject(:groups) { group.find(page: 2) }
      it { expect(groups[0].id).to eq 11 }
      it { expect(groups.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:groups) { group.find(page_size: 2) }
      it { expect(groups[0].id).to eq 1 }
      it { expect(groups.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:groups) { group.find(page: 2, page_size: 3) }
      it { expect(groups[0].id).to eq 4 }
      it { expect(groups.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:groups) { group.find(query: 'vol') }
      it { expect(groups[0].name).to eq 'volcanic' }
      it { expect(groups[1].name).to eq 'vol' }
    end

    context 'when find with pagination' do
      subject { group.find }
      its(:page) { should eq 1 }
      its(:page_size) { should eq 10 }
      its(:row_count) { should eq 20 }
      its(:page_count) { should eq 2 }
    end

    context 'when find with sort and order' do
      subject(:groups) { group.find(sort: 'id', order: 'desc') }
      it { expect(groups[0].id).to eq 20 }
      it { expect(groups[1].id).to eq 19 }
      it { expect(groups[2].id).to eq 18 }
    end
  end

  describe '#save' do
    let(:new_name) { 'new-group' }
    let(:new_description) { 'new-group-description' }
    subject(:group_save) { new_group }

    context 'when name nil' do
      before { group_save.name = nil }
      it { expect { group_save.save }.to raise_error group_error }
    end

    context 'when name is empty' do
      before { group_save.name = '' }
      it { expect { group_save.save }.to raise_error group_error }
    end

    context 'when update with existing name' do
      before { group_save.name = new_name }
      it { expect { group_save.save }.to raise_error group_error }
    end

    context 'when updating' do
      before do
        group_save.name = new_name
        group_save.description = new_description
        group_save.save
      end
      subject { group.find_by_id(group_save.id) }
      its(:name) { should eq new_name }
      its(:description) { should eq new_description }
    end
  end

  describe '#delete' do
    let(:group_id) { new_group.id }
    context 'when deleted' do
      before { new_group.delete }
      subject { group.find_by_id(group_id) }
      its(:active?) { should be false }
    end

    context 'when group already been deleted' do
      it { expect { new_group.delete }.to raise_error group_error }
    end
  end
end
