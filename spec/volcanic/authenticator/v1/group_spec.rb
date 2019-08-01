# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Group, :vcr do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:mock_name) { 'mock_name' }
  let(:mock_description) { 'mock_description' }
  let(:mock_permission_id) { [1, 2] }
  let(:group_error) { Volcanic::Authenticator::V1::GroupError }
  let(:new_group) { group.create(mock_name, mock_description, mock_permission_id) }

  describe '.create' do
    context 'when missing name' do
      it { expect { group.create(nil, mock_description) }.to raise_error group_error }
      it { expect { group.create('', mock_description) }.to raise_error group_error }
    end

    context 'when duplicate name' do
      before { group.create(mock_name, mock_description) }
      it { expect { group.create(mock_name, mock_description) }.to raise_error group_error }
    end

    context 'when invalid permission_id' do
      # it { expect { group.create(mock_name, mock_description, 'wrong_id') }.to raise_error group_error }
      it { expect { group.create(mock_name, mock_description, 123_456_789) }.to raise_error group_error }
    end

    context 'when success' do
      subject { new_group }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
    end
  end

  describe '.active?' do
    subject { group.find(1) }
    its(:active?) { should eq true }
  end

  describe '.find' do
    context 'when find by id' do
      subject { group.find(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:description) { should eq mock_description }
      its(:subject_id) { should eq 1 }
      its(:active?) { should eq true }
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
      subject(:groups) { group.find(pagination: true) }
      let(:mock_pagination_result) { { page: 1, pageSize: 10, rowCount: 20, pageCount: 2 } }
      it { expect(groups[:pagination]).to eq mock_pagination_result }
      it { expect(groups[:data].count).to eq 10 }
    end

    context 'when find with sort and order' do
      subject(:groups) { group.find(sort: 'id', order: 'desc') }
      it { expect(groups[0].id).to eq 20 }
      it { expect(groups[1].id).to eq 19 }
      it { expect(groups[2].id).to eq 18 }
    end
  end

  describe '.first' do
    context 'when received first object' do
      subject { group.first }
      its(:id) { should eq 1 }
    end
  end

  describe '.last' do
    context 'when received last object' do
      subject { group.last }
      its(:id) { should eq 20 }
    end
  end

  describe '.count' do
    subject { group.count }
    it { should eq 20 }
  end

  # describe 'Find' do
  #   context 'When find with default setting' do
  #     # this will return a default page: 1 and page_size: 10
  #     subject(:groups) { group.find }
  #     it { expect(groups[0].id).to eq 1 } # taking the first page
  #     it { expect(groups[0].name).to eq 'first-group' }
  #     it { expect(groups.count).to be <= 10 } # taking the page size to 10
  #   end
  #
  #   context 'When find with specific page' do
  #     subject(:groups) { group.find(page: 2) }
  #     it { expect(groups[0].id).to eq 11 }
  #     it { expect(groups[0].name).to eq 'eleventh-group' }
  #     it { expect(groups.count).to be <= 10 }
  #   end
  #
  #   context 'When find with specific page size' do
  #     subject(:groups) { group.find(page_size: 2) }
  #     it { expect(groups[0].id).to eq 1 }
  #     it { expect(groups[0].name).to eq 'first-group' }
  #     it { expect(groups.count).to be <= 2 }
  #   end
  #
  #   context 'When find with page and page size' do
  #     subject(:groups) { group.find(page: 2, page_size: 3) }
  #     it { expect(groups[0].id).to eq 4 }
  #     it { expect(groups[0].name).to eq 'fourth-group' }
  #     it { expect(groups.count).to be <= 3 }
  #   end
  #
  #   context 'When find with key_name' do
  #     subject(:groups) { group.find(key_name: 'gro') }
  #     it { expect(groups[0].name).to eq 'first-group' }
  #     it { expect(groups[1].name).to eq 'second-group' }
  #     it { expect(groups[2].name).to eq 'third-group' }
  #   end
  # end

  # describe 'Find by given id' do
  #   context 'When missing id' do
  #     it { expect { group.find(nil) }.to raise_error ArgumentError }
  #     it { expect { group.find('') }.to raise_error ArgumentError }
  #   end
  #
  #   context 'When invalid id' do
  #     it { expect { group.find('wrong_id') }.to raise_error group_error }
  #   end
  #
  #   context 'When retrieve by id' do
  #     subject { group.find(new_group.id) }
  #     its(:id) { should eq new_group.id }
  #     its(:name) { should eq new_group.name }
  #     its(:subject_id) { should eq new_group.subject_id }
  #     its(:active?) { should eq true }
  #   end
  # end

  describe '.save' do
    let(:new_name) { 'new-group' }
    let(:new_description) { 'new-group-description' }

    context 'when required field is nil' do
      before { new_group.name = nil }
      it { expect { new_group.save }.to raise_error group_error }
    end

    context 'when required field is empty' do
      before { new_group.name = '' }
      it { expect { new_group.save }.to raise_error group_error }
    end

    context 'when changed name' do
      before do
        new_group.name = new_name
        new_group.save
      end
      subject { group.find(new_group.id) }
      its(:name) { should eq new_name }
    end

    context 'when changed description' do
      before do
        new_group.description = new_description
        new_group.save
      end
      subject { group.find(new_group.id) }
      its(:description) { should eq new_description }
    end

    context 'when update with existing name' do
      before { new_group.name = new_name }
      it { expect { new_group.save }.to raise_error group_error }
    end
  end

  describe '.delete' do
    let(:group_id) { new_group.id }
    context 'when deleted' do
      before { new_group.delete }
      subject { group.find(group_id) }
      its(:active?) { should be false }
    end

    context 'when group already been deleted' do
      it { expect { new_group.delete }.to raise_error group_error }
    end

    context 'when invalid or non-exist id' do
      # it { expect { group.new(id: 'wrong-id').delete }.to raise_error group_error }
      it { expect { group.new(id: 123_456_789).delete }.to raise_error group_error }
    end
  end
end
