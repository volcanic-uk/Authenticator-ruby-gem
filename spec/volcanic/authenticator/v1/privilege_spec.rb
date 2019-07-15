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
  let(:new_privilege) { privilege.create(mock_scope, mock_permission_id, mock_group_id) }

  describe 'Create' do
    context 'When missing scope' do
      it { expect { privilege.create(nil, mock_permission_id) }.to raise_error privilege_error }
      it { expect { privilege.create('', mock_permission_id) }.to raise_error privilege_error }
    end

    context 'When missing permission_id' do
      it { expect { privilege.create(mock_scope, nil) }.to raise_error privilege_error }
      it { expect { privilege.create(mock_scope, '') }.to raise_error privilege_error }
    end

    context 'When invalid (not exists) permission_id' do
      it { expect { privilege.create(mock_scope, 'wrong-id') }.to raise_error privilege_error }
    end

    context 'When invalid (not exists) group_id' do
      it { expect { privilege.create(mock_scope, mock_permission_id, 'wrong-id') }.to raise_error privilege_error }
    end

    context 'When success' do
      subject { new_privilege }
      its(:id) { should eq 1 }
      its(:scope) { should eq mock_scope }
      its(:permission_id) { should eq mock_permission_id }
      its(:group_id) { should eq mock_group_id }
      its(:subject_id) { should eq mock_subject_id }
    end
  end

  describe 'Find' do
    context 'When find with default setting' do
      # this will return a default page: 1 and page_size: 10
      subject(:privileges) { privilege.find }
      it { expect(privileges[0].id).to eq 1 } # taking the first page
      it { expect(privileges[0].scope).to eq 'first-privilege-scope' }
      it { expect(privileges.count).to be <= 10 } # taking the page size to 10
    end

    context 'When find with specific page' do
      subject(:privileges) { privilege.find(page: 2) }
      it { expect(privileges[0].id).to eq 11 }
      it { expect(privileges[0].scope).to eq 'eleventh-privilege-scope' }
      it { expect(privileges.count).to be <= 10 }
    end

    context 'When find with specific page size' do
      subject(:privileges) { privilege.find(page_size: 2) }
      it { expect(privileges[0].id).to eq 1 }
      it { expect(privileges[0].scope).to eq 'first-privilege-scope' }
      it { expect(privileges.count).to be <= 2 }
    end

    context 'When find with page and page size' do
      subject(:privileges) { privilege.find(page: 2, page_size: 3) }
      it { expect(privileges[0].id).to eq 4 }
      it { expect(privileges[0].scope).to eq 'fourth-privilege-scope' }
      it { expect(privileges.count).to be <= 3 }
    end

    context 'When find with key_scope' do
      subject(:privileges) { privilege.find(key_scope: 'pri') }
      it { expect(privileges[0].scope).to eq 'first-privilege-scope' }
      it { expect(privileges[1].scope).to eq 'second-privilege-scope' }
      it { expect(privileges[2].scope).to eq 'third-privilege-scope' }
    end
  end

  describe 'Find by given id' do
    context 'When missing id' do
      it { expect { privilege.find_by_id(nil) }.to raise_error ArgumentError }
      it { expect { privilege.find_by_id('') }.to raise_error ArgumentError }
    end

    context 'When invalid (not exists) id' do
      it { expect { privilege.find_by_id('wrong_id') }.to raise_error privilege_error }
    end

    context 'When retrieve by id' do
      subject { privilege.find_by_id(new_privilege.id) }
      its(:id) { should eq 1 }
      its(:scope) { should eq mock_scope }
      its(:permission_id) { should eq mock_permission_id }
      its(:group_id) { should eq mock_group_id }
      its(:subject_id) { should eq mock_subject_id }
    end
  end

  describe 'Update' do
    let(:new_scope) { 'new-scope' }
    let(:new_permission_id) { 2 }
    let(:new_group_id) { 2 }

    context 'When required field (name) is missing' do
      it 'name is nil' do
        new_privilege.scope = nil
        expect { new_privilege.save }.to raise_error privilege_error
      end

      it 'name is empty' do
        new_privilege.scope = ''
        expect { new_privilege.save }.to raise_error privilege_error
      end
    end

    context 'When required field (permission id) is missing' do
      it 'when nil' do
        new_privilege.permission_id = nil
        expect { new_privilege.save }.to raise_error privilege_error
      end

      it 'when empty' do
        new_privilege.permission_id = ''
        expect { new_privilege.save }.to raise_error privilege_error
      end
    end

    context 'When changed scope' do
      before do
        new_privilege.scope = new_scope
        new_privilege.save
      end
      subject { privilege.find_by_id(new_privilege.id) }
      its(:scope) { should eq new_scope }
    end

    context 'When changed permission id' do
      before do
        new_privilege.permission_id = new_permission_id
        new_privilege.save
      end
      subject { privilege.find_by_id(new_privilege.id) }
      its(:permission_id) { should eq new_permission_id }
    end

    context 'When changed group id' do
      before do
        new_privilege.group_id = new_group_id
        new_privilege.save
      end
      subject { privilege.find_by_id(new_privilege.id) }
      its(:group_id) { should eq new_group_id }
    end

    context 'When invalid (non exists) permission id' do
      before { new_privilege.permission_id = 123_456_789 }
      it { expect { new_privilege.save }.to raise_error privilege_error }
    end

    context 'When invalid (non exists) group id' do
      before { new_privilege.group_id = 123_456_789 }
      it { expect { new_privilege.save }.to raise_error privilege_error }
    end
  end

  describe 'Delete' do
    let(:privilege_id) { new_privilege.id }
    context 'When deleted' do
      before { new_privilege.delete }
      subject { privilege.find_by_id(privilege_id) }
      it { expect { privilege.find_by_id(privilege_id) }.to raise_error privilege_error }
    end

    context 'When have been deleted' do
      before { new_privilege.delete }
      it { expect { new_privilege.delete }.to raise_error privilege_error }
    end

    context 'When invalid or non-exist id' do
      it { expect { privilege.new(id: 'wrong-id').delete }.to raise_error privilege_error }
      it { expect { privilege.new(id: 123_456_789).delete }.to raise_error privilege_error }
    end
  end
end
