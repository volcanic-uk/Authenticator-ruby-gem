RSpec.describe Volcanic::Authenticator::V1::Group do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:new_identity) { identity.register(mock_name) }
  let(:new_permission) { permission.create(mock_name, new_identity.id) }
  let(:new_group) { group.create(mock_name, mock_description, new_permission.id) }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }

  describe 'Create' do
    subject { group.create(mock_name, 'mock_description', new_permission.id) }

    context 'When missing name' do
      it { expect { group.create(nil, mock_description, new_permission.id) }.to raise_error Volcanic::Authenticator::GroupError }
      it { expect { group.create('', mock_description, new_permission.id) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When invalid/short name' do
      it { expect { group.create('shrt', mock_description, new_permission.id) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When duplicate name' do
      let(:duplicate_name) { SecureRandom.hex 6 }
      before { group.create(duplicate_name, mock_description, new_permission.id) }
      it { expect { group.create(duplicate_name, mock_description, new_permission.id) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When invalid permission_id' do
      it { expect { group.create(mock_name, mock_description, mock_description) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When creating' do
      it { is_expected.to be_an group }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:creator_id) { should_not be nil }
      its(:description) { should_not be nil }
    end

    context 'When description is missing' do
      subject { group.create(mock_name, nil, new_permission.id) }
      its(:description) { should be nil }
    end

    context 'When permission is missing' do
      subject { group.create(mock_name, mock_description, nil) }
      it { is_expected.to be_an group }
    end
  end

  describe 'Retrieve' do
    context 'When retrieve all' do
      subject { group.retrieve }
      it { should be_an_instance_of(Array) }
    end

    context 'When missing id' do
      it { expect { group.retrieve(nil) }.to raise_error Volcanic::Authenticator::ConnectionError }
      it { expect { group.retrieve('') }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When invalid id' do
      it { expect { group.retrieve('wrong_id') }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When retrieve by id' do
      subject { group.retrieve(new_group.id) }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:creator_id) { should_not be nil }
      its(:active) { should_not be nil }
    end
  end

  describe 'Update' do
    let(:attr) { { name: SecureRandom.hex(6) } }
    context 'When missing id' do
      it { expect { group.update(nil, attr) }.to raise_error Volcanic::Authenticator::ConnectionError }
      it { expect { group.update('', attr) }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When invalid id' do
      it { expect { group.update('wrong_id', attr) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When invalid attributes' do
      it { expect { group.update(new_group.id, wrong_attr: SecureRandom.hex(6)) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When attributes not a hash value' do
      it { expect { group.update(new_group.id, 'not_hash') }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When success' do
      subject { group.update(new_group.id, attr) }
      it { should_not be raise_error }
    end
  end

  describe 'Delete' do
    context 'When missing id' do
      it { expect { group.delete(nil) }.to raise_error Volcanic::Authenticator::ConnectionError }
      it { expect { group.delete('') }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When invalid id' do
      it { expect { group.delete('wrong_id') }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When success' do
      subject { group.delete(new_group.id) }
      it { should_not be raise_error }
    end
  end
end