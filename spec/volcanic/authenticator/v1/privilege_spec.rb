# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Privilege, :vcr do
  before { Configuration.set }
  let(:privilege) { Volcanic::Authenticator::V1::Privilege }
  let(:mock_privilege_id) { 1 }
  let(:mock_permission_id) { 1 }
  let(:mock_group_permission_id) { 1 }
  let(:mock_permission) { Volcanic::Authenticator::V1::Permission.new(id: mock_permission_id) }
  let(:mock_group_permission) { Volcanic::Authenticator::V1::GroupPermission.new(id: mock_group_permission_id) }
  let(:mock_scope) { 'vrn:stack:1:resource/*' }
  let(:privilege_error) { Volcanic::Authenticator::V1::PrivilegeError }
  let(:new_privilege) { privilege.create(mock_scope) }

  describe '#create' do
    context 'when invalid scope' do
      it 'nil or empty value' do
        expect { privilege.create(nil) }.to raise_error privilege_error
        expect { privilege.create('') }.to raise_error privilege_error
      end

      it 'wrong pattern' do
        expect { privilege.create('vrn:stack:resource/*') }.to raise_error privilege_error
      end
    end

    context 'when invalid permission' do
      it 'not a number' do
        expect { privilege.create(mock_scope, permission: 'not-number') }.to raise_error privilege_error
      end

      it 'not existed' do
        expect { privilege.create(mock_scope, permission: 10_000) }.to raise_error privilege_error
      end
    end

    context 'when invalid group permission' do
      it 'not a number' do
        expect { privilege.create(mock_scope, group_permission: 'not-number') }.to raise_error privilege_error
      end

      it 'not existed' do
        expect { privilege.create(mock_scope, group_permission: 10_000) }.to raise_error privilege_error
      end
    end

    context 'when valid' do
      subject(:instance) { privilege.create(mock_scope, permission: mock_permission, group_permission: mock_group_permission) }
      its(:scope) { should eq mock_scope }
      its(:allow?) { should eq true }

      it 'permission' do
        expect(instance.permission.is_a?(Volcanic::Authenticator::V1::Permission)).to eq true
        expect(instance.permission.id).to eq mock_permission_id
      end

      it 'group_permission' do
        expect(instance.group_permission.is_a?(Volcanic::Authenticator::V1::GroupPermission)).to eq true
        expect(instance.group_permission.id).to eq mock_group_permission_id
      end
    end
  end

  describe '#save' do # update privilege
    let(:instance) { privilege.find_by_id(mock_privilege_id) }
    context 'when updating scope' do
      context 'is invalid' do
        it 'with nil or empty value' do
          instance.scope = nil
          expect { instance.save }.to raise_error privilege_error
        end

        it 'with wrong pattern' do
          instance.scope = 'vrn:stack:resource/*'
          expect { instance.save }.to raise_error privilege_error
        end
      end

      context 'is valid' do
        subject { instance }
        before do
          instance.scope = mock_scope
          instance.save
        end
        its(:scope) { should eq mock_scope }
      end
    end

    context 'when updating permission' do
      context 'is invalid' do
        it 'empty value' do
          instance.permission = ''
          expect { instance.save }.to raise_error privilege_error
        end

        it 'not existed' do
          instance.permission = 10_000
          expect { instance.save }.to raise_error privilege_error
        end
      end

      context 'is valid' do
        subject { instance }
        context 'with id' do
          before do
            instance.permission = mock_permission_id
            instance.save
          end
          its(:permission) { should be_a Volcanic::Authenticator::V1::Permission }
          it { expect(instance.permission.id).to eq mock_permission_id }
        end

        context 'with permission object' do
          before do
            instance.permission = mock_permission
            instance.save
          end
          it { expect(instance.permission.id).to eq mock_permission.id }
        end
      end
    end

    context 'when updating group permission' do
      context 'is invalid' do
        it 'empty value' do
          instance.group_permission = ''
          expect { instance.save }.to raise_error privilege_error
        end

        it 'not existed' do
          instance.group_permission = 10_000
          expect { instance.save }.to raise_error privilege_error
        end
      end

      context 'is valid' do
        subject { instance }
        context 'using integer id' do
          before do
            instance.group_permission = mock_group_permission_id
            instance.save
          end
          its(:group_permission) { should be_a Volcanic::Authenticator::V1::GroupPermission }
          it { expect(instance.group_permission.id).to eq mock_group_permission_id }
        end

        context 'using permission object' do
          before do
            instance.group_permission = mock_group_permission
            instance.save
          end
          it { expect(instance.group_permission.id).to eq mock_group_permission.id }
        end
      end
    end
  end

  describe '#find_by_id' do
    subject { privilege.find_by_id(mock_privilege_id) }
    its(:id) { should eq mock_privilege_id }
    its(:scope) { should eq mock_scope }
    its(:permission) { should be_a Volcanic::Authenticator::V1::Permission }
    its(:group_permission) { should be_a Volcanic::Authenticator::V1::GroupPermission }
    its(:allow?) { should eq true }
  end

  describe '#find' do
    context 'with specific page' do
      subject(:privileges) { privilege.find(page: 2) }
      it { expect(privileges.page).to eq 2 }
      it { expect(privileges.page_size).to be <= 10 } # default page_size is 10
    end

    context 'with specific page size' do
      subject(:privileges) { privilege.find(page_size: 2) }
      it { expect(privileges.page).to eq 1 } # default page_size is 10
      it { expect(privileges.page_size).to eq 2 }
    end

    context 'with specific page and page size' do
      subject(:privileges) { privilege.find(page: 2, page_size: 3) }
      it { expect(privileges.page).to eq 2 }
      it { expect(privileges.page_size).to eq 3 }
    end

    context 'with query' do
      subject(:privileges) { privilege.find(query: 'vrn') }
      it { expect(privileges.page_size).to be <= 10 }
      it { expect(privileges[0].scope).to eq mock_scope }
    end
  end

  describe '#delete' do
    context 'when invalid id' do
      context 'is nil value' do
        let(:invalid_id) { nil }
        subject(:instance) { privilege.new(id: invalid_id) }
        it { expect { instance.delete }.to raise_error privilege_error }
      end

      context 'is empty value' do
        let(:invalid_id) { '' }
        subject(:instance) { privilege.new(id: invalid_id) }
        it { expect { instance.delete }.to raise_error privilege_error }
      end

      context 'is not exist' do
        let(:invalid_id) { 10_000 }
        subject(:instance) { privilege.new(id: invalid_id) }
        it { expect { instance.delete }.to raise_error privilege_error }
      end
    end

    context 'when valid id' do
      subject(:instance) { privilege.new(id: mock_privilege_id) }
      it { expect { instance.delete }.to_not raise_error }
    end
  end
end
