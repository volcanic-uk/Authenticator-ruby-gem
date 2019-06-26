# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Privilege, :vcr do
  before { Configuration.set }
  let(:privilege) { Volcanic::Authenticator::V1::Privilege }
  let(:mock_scope) { SecureRandom.hex(6) }
  # need to create permission and group permission
  subject(:new_privilege) { privilege.create(mock_scope) }

  describe 'Create' do
    context 'When missing scope' do
      it { expect(privilege.create(nil)).not_to be raise_error }
      it { expect(privilege.create('')).not_to be raise_error }
    end

    context 'When missing permission_id' do
      it { expect(privilege.create(mock_scope, nil)).not_to be raise_error }
      it { expect(privilege.create(mock_scope, '')).not_to be raise_error }
    end

    context 'When invalid permission_id' do
      it { expect { privilege.create(mock_scope, 'wrong-id', nil) }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When missing group_id' do
      it { expect(privilege.create(mock_scope, nil, nil)).not_to be raise_error }
      it { expect(privilege.create(mock_scope, '', '')).not_to be raise_error }
    end

    context 'When invalid group_id' do
      it { expect { privilege.create(mock_scope, nil, 'wrong-id') }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When success' do
      it { is_expected.to be_an privilege }
      its(:scope) { should_not be nil }
      its(:id) { should_not be nil }
      # its(:permission_id) { should_not be nil }
      # its(:group_id) { should_not be nil }
    end
  end

  describe 'Get all' do
    subject { privilege.all }
    it { should be_an_instance_of(Array) }
  end

  describe 'Find by given id' do
    context 'When missing id' do
      it { expect { privilege.find_by_id(nil) }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
      it { expect { privilege.find_by_id('') }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When invalid id' do
      it { expect { privilege.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When retrieve by id' do
      subject { privilege.find_by_id(new_privilege.id) }
      its(:scope) { should_not be nil }
      its(:id) { should_not be nil }
      its(:allow) { should be true }
      # its(:permission_id) { should_not be nil }
      # its(:group_id) { should_not be nil }
    end
  end

  describe 'Update' do
    let(:attr) { { scope: SecureRandom.hex(6) } }
    # context 'When missing id' do
    #   it { expect { privilege.update(nil, attr) }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    #   it { expect { privilege.update('', attr) }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    # end

    context 'When invalid id' do
      it { expect { privilege.update('wrong_id', attr) }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When invalid attributes' do
      it { expect(privilege.update(new_privilege.id, wrong_attr: SecureRandom.hex(6))).not_to be raise_error }
    end

    context 'When attributes not a hash value' do
      it { expect { privilege.update(new_privilege.id, 'not_hash') }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When success' do
      subject { privilege.update(new_privilege.id, attr) }
      it { should_not be raise_error }
    end
  end

  describe 'Delete' do
    context 'When missing id' do
      it { expect { privilege.delete(nil) }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
      it { expect { privilege.delete('') }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When invalid id' do
      it { expect { privilege.delete('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PrivilegeError }
    end

    context 'When success' do
      subject { privilege.delete(new_privilege.id) }
      it { should_not be raise_error }
    end
  end
end
