# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Privilege, :vcr do
  before { Configuration.set }
  let(:privilege) { Volcanic::Authenticator::V1::Privilege }
  let(:mock_scope) { 'mock_scope' }
  let(:mock_description) { 'mock_description' }
  let(:mock_group_id) { 1 }
  let(:mock_permission_id) { 1 }
  let(:mock_subject_id) { 2 }
  let(:privilege_error) { Volcanic::Authenticator::V1::PrivilegeError }
  let(:new_privilege) { privilege.create(mock_scope, mock_permission_id, mock_group_id, true) }

  describe '.create' do
    context 'when missing scope' do
      it { expect { privilege.create(nil, mock_permission_id) }.to raise_error privilege_error }
      it { expect { privilege.create('', mock_permission_id) }.to raise_error privilege_error }
    end

    context 'when missing permission_id' do
      it { expect { privilege.create(mock_scope, nil) }.to raise_error privilege_error }
      it { expect { privilege.create(mock_scope, '') }.to raise_error privilege_error }
    end

    context 'when invalid (not exists) permission_id' do
      it { expect { privilege.create(mock_scope, 'wrong-id') }.to raise_error privilege_error }
    end

    context 'when invalid (not exists) group_id' do
      it { expect { privilege.create(mock_scope, mock_permission_id, 'wrong-id') }.to raise_error privilege_error }
    end

    context 'when created' do
      subject { new_privilege }
      its(:id) { should eq 1 }
      its(:scope) { should eq mock_scope }
      its(:permission_id) { should eq mock_permission_id }
      its(:group_id) { should eq mock_group_id }
      its(:subject_id) { should eq mock_subject_id }
      its(:allow?) { should eq true }
    end
  end

  describe '.find' do
    context 'when find by id' do
      subject { privilege.find(1) }
      its(:id) { should eq 1 }
      its(:scope) { should eq mock_scope }
      its(:permission_id) { should eq mock_permission_id }
      its(:group_id) { should eq mock_group_id }
      its(:subject_id) { should eq mock_subject_id }
      its(:allow?) { should eq true }
    end

    context 'when find with specific page' do
      subject(:privileges) { privilege.find(page: 2) }
      it { expect(privileges[0].id).to eq 11 }
      it { expect(privileges.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:privileges) { privilege.find(page_size: 2) }
      it { expect(privileges[0].id).to eq 1 }
      it { expect(privileges.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:privileges) { privilege.find(page: 2, page_size: 3) }
      it { expect(privileges[0].id).to eq 4 }
      it { expect(privileges.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:privileges) { privilege.find(query: 'vol') }
      it { expect(privileges[0].scope).to eq 'volcanic' }
      it { expect(privileges[1].scope).to eq 'vol' }
    end

    context 'when find with pagination' do
      subject(:privileges) { privilege.find(pagination: true) }
      let(:mock_pagination) { { page: 1, pageSize: 10, rowCount: 20, pageCount: 3 } }
      it { expect(privileges[:pagination]). to eq mock_pagination }
      it { expect(privileges[:data].count). to eq 10 }
    end
  end

  describe '.first' do
    context 'when received first object' do
      subject { privilege.first }
      its(:id) { should eq 1 }
    end
  end

  describe '.last' do
    context 'when received last object' do
      subject { privilege.last }
      its(:id) { should eq 20 }
    end
  end

  describe '.count' do
    subject { privilege.count }
    it { should eq 20 }
  end

  describe '.save' do
    let(:new_scope) { 'new-scope' }
    let(:new_permission_id) { 2 }
    let(:new_group_id) { 2 }
    let(:mock_allow) { false }

    context 'when required field (name) is missing' do
      it 'name is nil' do
        new_privilege.scope = nil
        expect { new_privilege.save }.to raise_error privilege_error
      end

      it 'name is empty' do
        new_privilege.scope = ''
        expect { new_privilege.save }.to raise_error privilege_error
      end
    end

    context 'when required field (permission id) is missing' do
      # it 'when nil' do
      #   new_privilege.permission_id = nil
      #   expect { new_privilege.save }.to raise_error privilege_error
      # end

      it 'when empty' do
        new_privilege.permission_id = ''
        expect { new_privilege.save }.to raise_error privilege_error
      end
    end

    context 'when changed scope' do
      before do
        new_privilege.scope = new_scope
        new_privilege.save
      end
      subject { privilege.find(new_privilege.id) }
      its(:scope) { should eq new_scope }
    end

    context 'when changed permission id' do
      before do
        new_privilege.permission_id = new_permission_id
        new_privilege.save
      end
      subject { privilege.find(new_privilege.id) }
      its(:permission_id) { should eq new_permission_id }
    end

    context 'when changed group id' do
      before do
        new_privilege.group_id = new_group_id
        new_privilege.save
      end
      subject { privilege.find(new_privilege.id) }
      its(:group_id) { should eq new_group_id }
    end

    context 'when invalid (non exists) permission id' do
      before { new_privilege.permission_id = 123_456_789 }
      it { expect { new_privilege.save }.to raise_error privilege_error }
    end

    context 'when invalid (non exists) group id' do
      before { new_privilege.group_id = 123_456_789 }
      it { expect { new_privilege.save }.to raise_error privilege_error }
    end
  end

  describe '.delete' do
    let(:privilege_id) { new_privilege.id }
    context 'when deleted' do
      before { new_privilege.delete }
      subject { privilege.find(privilege_id) }
      it { expect { privilege.find(privilege_id) }.to raise_error privilege_error }
    end

    context 'when have been deleted' do
      before { new_privilege.delete }
      it { expect { new_privilege.delete }.to raise_error privilege_error }
    end

    context 'when invalid or non-exist id' do
      # it { expect { privilege.new(id: 'wrong-id').delete }.to raise_error privilege_error }
      it { expect { privilege.new(id: 123_456_789).delete }.to raise_error privilege_error }
    end
  end
end
