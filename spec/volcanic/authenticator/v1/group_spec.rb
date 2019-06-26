# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Group, :vcr do
  before { Configuration.set }
  let(:group) { Volcanic::Authenticator::V1::Group }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }
  subject(:new_group) { group.create(mock_name, [], mock_description) }

  describe 'Create' do
    context 'When missing name' do
      it { expect { group.create(nil, [], mock_description) }.to raise_error Volcanic::Authenticator::V1::GroupError }
      it { expect { group.create('', [], mock_description) }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When duplicate name' do
      let(:duplicate_name) { SecureRandom.hex 6 }
      before { group.create(duplicate_name, [], mock_description) }
      it { expect { group.create(duplicate_name, [], mock_description) }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When invalid permission_id' do
      it { expect { group.create(mock_name, ['wrong_id'], mock_description) }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When creating' do
      it { is_expected.to be_an group }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:creator_id) { should_not be nil }
    end

    # context 'When description is missing' do
    #   subject { group.create(mock_name, nil, new_) }
    #   its(:description) { should be nil }
    # end

    # context 'When permission is missing' do
    #   subject {  group.create(mock_name, nil, mock_description) }
    #   it { is_expected.to be_an group }
    # end
  end

  describe 'Get all' do
    subject { group.all }
    it { should be_an_instance_of(Array) }
  end

  describe 'Find by given id' do
    context 'When missing id' do
      it { expect { group.find_by_id(nil) }.to raise_error Volcanic::Authenticator::V1::GroupError }
      it { expect { group.find_by_id('') }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When invalid id' do
      it { expect { group.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When retrieve by id' do
      subject { group.find_by_id(new_group.id) }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
      its(:creator_id) { should_not be nil }
      its(:active) { should_not be nil }
    end
  end

  describe 'Update' do
    let(:attr) { { name: SecureRandom.hex(6) } }
    context 'When missing id' do
      it { expect { group.update(nil, attr) }.to raise_error Volcanic::Authenticator::V1::GroupError }
      it { expect { group.update('', attr) }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When invalid id' do
      it { expect { group.update('wrong_id', attr) }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When invalid attributes' do
      it { expect { group.update(new_group.id, wrong_attr: SecureRandom.hex(6)) }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When attributes not a hash value' do
      it { expect { group.update(new_group.id, 'not_hash') }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When success' do
      subject { group.update(new_group.id, attr) }
      it { should_not be raise_error }
    end

    describe 'attributes with descriptions' do
      let(:has_descr) { { name: SecureRandom.hex(6), description: mock_description } }
      let(:no_descr) { { name: SecureRandom.hex(6), description: nil } }
      context 'When missing description value' do
        it { expect { group.update(new_group.id, no_descr) }.to raise_error Volcanic::Authenticator::V1::GroupError }
      end
      context 'When success' do
        subject { group.update(new_group.id, has_descr) }
        it { should_not be raise_error }
      end
    end
  end

  describe 'Delete' do
    context 'When missing id' do
      it { expect { group.delete(nil) }.to raise_error Volcanic::Authenticator::V1::GroupError }
      it { expect { group.delete('') }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When invalid id' do
      it { expect { group.delete('wrong_id') }.to raise_error Volcanic::Authenticator::V1::GroupError }
    end

    context 'When success' do
      subject { group.delete(new_group.id) }
      it { should_not be raise_error }
    end
  end
end
