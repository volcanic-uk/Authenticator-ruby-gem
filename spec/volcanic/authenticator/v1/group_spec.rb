RSpec.describe Volcanic::Authenticator::V1::Group do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:permission) { Volcanic::Authenticator::V1::Permission.create(mock_name) }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }
  subject(:new_group) { group.create(mock_name, [permission.id], mock_description) }

  describe 'Create', :vcr do
    context 'When missing name' do
      it { expect { group.create(nil, [permission.id], mock_description) }.to raise_error Volcanic::Authenticator::GroupError }
      it { expect { group.create('', [permission.id], mock_description) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When invalid/short name' do
      it { expect { group.create('shrt', [permission.id], mock_description) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When duplicate name' do
      let(:duplicate_name) { SecureRandom.hex 6 }
      before { group.create(duplicate_name, [permission.id], mock_description) }
      it { expect { group.create(duplicate_name, [permission.id], mock_description) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When invalid permission_id' do
      it { expect { group.create(mock_name, ['wrong_id'], mock_description) }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When creating' do
      it { is_expected.to be_an group }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:creator_id) { should_not be nil }
    end

    # context 'When description is missing' do
    #   subject { group.create(mock_name, nil, new_permission.id) }
    #   its(:description) { should be nil }
    # end

    context 'When permission is missing' do
      subject {  group.create(mock_name, nil, mock_description) }
      it { is_expected.to be_an group }
    end
  end

  describe 'Get all' do
    subject { group.all }
    it { should be_an_instance_of(Array) }
  end

  describe 'Find by given id', :vcr do

    context 'When missing id' do
      it { expect { group.find_by_id(nil) }.to raise_error Volcanic::Authenticator::GroupError }
      it { expect { group.find_by_id('') }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When invalid id' do
      it { expect { group.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::GroupError }
    end

    context 'When retrieve by id' do
      subject { group.find_by_id(new_group.id) }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:creator_id) { should_not be nil }
      its(:active) { should_not be nil }
    end
  end

  describe 'Update', :vcr do
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

  describe 'Delete', :vcr do
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