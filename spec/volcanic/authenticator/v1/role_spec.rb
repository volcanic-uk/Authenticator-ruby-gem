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
  describe '.create' do
    context 'when missing name' do
      it { expect { role.create(nil, mock_service_id) }.to raise_error role_error }
      it { expect { role.create('', mock_service_id) }.to raise_error role_error }
    end

    context 'when duplicate name' do
      before { role.create(mock_name, mock_service_id) }
      it { expect { role.create(mock_name, mock_service_id) }.to raise_error role_error }
    end

    context 'when creating' do
      subject { role.create(mock_name, mock_service_id) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:service_id) { should eq mock_service_id }
      its(:subject_id) { should eq 2 }
    end
  end

  describe '.find' do
    context 'when find by id' do
      subject { role.find(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:service_id) { should eq 1 }
      its(:subject_id) { should eq 1 }
    end

    context 'when find with specific page' do
      subject(:roles) { role.find(page: 2) }
      it { expect(roles[0].id).to eq 11 }
      it { expect(roles.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:roles) { role.find(page_size: 2) }
      it { expect(roles[0].id).to eq 1 }
      it { expect(roles.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:roles) { role.find(page: 2, page_size: 3) }
      it { expect(roles[0].id).to eq 4 }
      it { expect(roles.count).to be <= 3 }
    end

    # context 'when find with query' do
    #   subject(:roles) { role.find(query: 'vol') }
    #   it { expect(roles[0].name).to eq 'volcanic' }
    #   it { expect(roles[1].name).to eq 'vol' }
    # end

    context 'when find with pagination' do
      subject(:roles) { role.find(pagination: true) }
      let(:mock_pagination) { { page: 1, pageSize: 10, rowCount: 20, pageCount: 2 } }
      it { expect(roles[:pagination]). to eq mock_pagination }
      it { expect(roles[:data].count). to eq 10 }
    end
  end

  describe '.first' do
    context 'when received first object' do
      subject { role.first }
      its(:id) { should eq 1 }
    end
  end

  describe '.last' do
    context 'when received last object' do
      subject { role.last }
      its(:id) { should eq 20 }
    end
  end

  describe '.count' do
    subject { role.count }
    it { should eq 20 }
  end

  # describe 'Find' do
  #   context 'when find with default setting' do
  #     # this will return a default page: 1 and page_size: 10
  #     subject(:roles) { role.find }
  #     it { expect(roles[0].id).to eq 1 } # taking the first page
  #     it { expect(roles[0].name).to eq 'first-role' }
  #     it { expect(roles.count).to be <= 10 } # taking the page size to 10
  #   end
  #
  #   context 'when find with specific page' do
  #     subject(:roles) { role.find(page: 2) }
  #     it { expect(roles[0].id).to eq 11 }
  #     it { expect(roles[0].name).to eq 'eleventh-role' }
  #     it { expect(roles.count).to be <= 10 }
  #   end
  #
  #   context 'when find with specific page size' do
  #     subject(:roles) { role.find(page_size: 2) }
  #     it { expect(roles[0].id).to eq 1 }
  #     it { expect(roles[0].name).to eq 'first-role' }
  #     it { expect(roles.count).to be <= 2 }
  #   end
  #
  #   context 'when find with page and page size' do
  #     subject(:roles) { role.find(page: 2, page_size: 3) }
  #     it { expect(roles[0].id).to eq 4 }
  #     it { expect(roles[0].name).to eq 'fourth-role' }
  #     it { expect(roles.count).to be <= 3 }
  #   end
  # end
  #
  # describe 'Find by given id' do
  #   subject { role.find(new_role.id) }
  #   context 'when missing id' do
  #     it { expect { role.find(nil) }.to raise_error ArgumentError }
  #     it { expect { role.find('') }.to raise_error ArgumentError }
  #   end
  #
  #   context 'when invalid id' do
  #     it { expect { role.find('wrong_id') }.to raise_error role_error }
  #     it { expect { role.find(123_456_789) }.to raise_error role_error }
  #   end
  #
  #   context 'when success' do
  #     its(:name) { should eq new_role.name }
  #     its(:id) { should eq new_role.id }
  #     its(:service_id) { should eq new_role.service_id }
  #     its(:subject_id) { should eq new_role.subject_id }
  #   end
  # end

  describe '.save' do
    let(:new_name) { 'new-role' }

    context 'when required field is nil' do
      before { new_role.name = nil }
      it { expect { new_role.save }.to raise_error role_error }
    end

    context 'when required field is empty' do
      before { new_role.name = nil }
      it { expect { new_role.save }.to raise_error role_error }
    end

    context 'when changed name' do
      before do
        new_role.name = new_name
        new_role.save
      end
      subject { role.find(new_role.id) }
      its(:name) { should eq new_name }
    end

    context 'when update with existing name' do
      before { new_role.name = new_name }
      it { expect { new_role.save }.to raise_error role_error }
    end
  end

  describe '.delete' do
    let(:role_id) { new_role.id }
    context 'when deleted' do
      before { new_role.delete }
      it { expect { role.find(role_id) }.to raise_error role_error }
    end

    context 'when role already been deleted' do
      before { new_role.delete }
      it { expect { new_role.delete }.to raise_error role_error }
    end

    context 'when invalid or non-exist id' do
      # it { expect { role.new(id: 'wrong-id').delete }.to raise_error role_error }
      it { expect { role.new(id: 123_456_789).delete }.to raise_error role_error }
    end
  end
end
