# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Principal, :vcr do
  before { Configuration.set }
  let(:principal) { Volcanic::Authenticator::V1::Principal }
  let(:mock_name) { 'mock_name' }
  let(:mock_dataset_id) { 1 }
  let(:mock_roles) { [1, 2] }
  let(:mock_privileges) { [3, 4] }
  let(:principal_error) { Volcanic::Authenticator::V1::PrincipalError }
  let(:new_principal) { Volcanic::Authenticator::V1::Principal.create(mock_name, mock_dataset_id, mock_roles, mock_privileges) }
  describe 'Create' do
    context 'When missing name' do
      it { expect { principal.create(nil, 1) }.to raise_error principal_error }
      it { expect { principal.create('', 1) }.to raise_error principal_error }
    end

    context 'When duplicate name' do
      before { principal.create(mock_name, mock_dataset_id) }
      it { expect { principal.create(mock_name, mock_dataset_id) }.to raise_error principal_error }
    end

    context 'When missing dataset_id' do
      it { expect { principal.create(mock_name, nil) }.to raise_error principal_error }
    end

    context 'When success' do
      subject { new_principal }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
    end
  end

  describe 'Find' do
    context 'When find with default setting' do
      # this will return a default page: 1 and page_size: 10
      subject(:principals) { principal.find }
      it { expect(principals[0].id).to eq 1 } # taking the first page
      it { expect(principals[0].name).to eq 'first-principal' }
      it { expect(principals.count).to be <= 10 } # taking the page size to 10
    end

    context 'When find with specific page' do
      subject(:principals) { principal.find(page: 2) }
      it { expect(principals[0].id).to eq 11 }
      it { expect(principals[0].name).to eq 'eleventh-principal' }
      it { expect(principals.count).to be <= 10 }
    end

    context 'When find with specific page size' do
      subject(:principals) { principal.find(page_size: 2) }
      it { expect(principals[0].id).to eq 1 }
      it { expect(principals[0].name).to eq 'first-principal' }
      it { expect(principals.count).to be <= 2 }
    end

    context 'When find with page and page size' do
      subject(:principals) { principal.find(page: 2, page_size: 3) }
      it { expect(principals[0].id).to eq 4 }
      it { expect(principals[0].name).to eq 'fourth-principal' }
      it { expect(principals.count).to be <= 3 }
    end
  end

  describe 'Find by given id' do
    subject { principal.find_by_id(new_principal.id) }
    context 'When missing id' do
      it { expect { principal.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { principal.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid id' do
      it { expect { principal.find_by_id('wrong_id') }.to raise_error principal_error }
    end

    context 'When success' do
      its(:id) { should eq new_principal.id }
      its(:name) { should eq new_principal.name }
      its(:dataset_id) { should eq new_principal.dataset_id }
    end
  end

  describe 'Update' do
    let(:new_name) { 'new-principal' }

    context 'When required field is nil' do
      before { new_principal.name = nil }
      it { expect { new_principal.save }.to raise_error principal_error }
    end

    context 'When required field is empty' do
      before { new_principal.name = nil }
      it { expect { new_principal.save }.to raise_error principal_error }
    end

    context 'When changed name' do
      before do
        new_principal.name = new_name
        new_principal.save
      end
      subject { principal.find_by_id(new_principal.id) }
      its(:name) { should eq new_name }
    end

    context 'When update with existing name' do
      before { new_principal.name = new_name }
      it { expect { new_principal.save }.to raise_error principal_error }
    end
  end

  describe 'Delete' do
    let(:principal_id) { new_principal.id }
    context 'When deleted' do
      before { new_principal.delete }
      subject { principal.find_by_id(principal_id) }
      its(:active?) { should be false }
    end

    context 'when principal already been deleted' do
      it { expect { new_principal.delete }.to raise_error principal_error }
    end

    context 'When invalid or non-exist id' do
      it { expect { principal.new(id: 'wrong-id').delete }.to raise_error principal_error }
      it { expect { principal.new(id: 123_456_789).delete }.to raise_error principal_error }
    end
  end
end
