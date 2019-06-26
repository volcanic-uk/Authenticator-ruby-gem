# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Permission, :vcr do
  before { Configuration.set }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }
  describe 'Permission' do
    subject(:new_permission) { permission.create(mock_name, mock_description) }
    describe 'Create' do
      context 'When missing name' do
        it { expect { permission.create(nil, mock_description) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
        it { expect { permission.create('', mock_description) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When missing description' do
        it { expect { permission.create(mock_name, nil) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
        it { expect { permission.create(mock_name, '') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When success' do
        its(:name) { should_not be nil }
        its(:id) { should_not be nil }
        its(:creator_id) { should_not be nil }
      end
    end

    describe 'Get all' do
      subject { permission.all }
      it { should be_an_instance_of(Array) }
    end

    describe 'Find by given id' do
      context 'When missing id' do
        it { expect { permission.find_by_id(nil) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
        it { expect { permission.find_by_id('') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When invalid id' do
        it { expect { permission.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When retrieve by id' do
        subject { permission.find_by_id(new_permission.id) }
        its(:name) { should_not be nil }
        its(:id) { should_not be nil }
        its(:creator_id) { should_not be nil }
        its(:active) { should_not be nil }
      end
    end

    describe 'Update' do
      let(:attr) { { name: SecureRandom.hex(6) } }
      context 'When missing id' do
        it { expect { permission.update(nil, attr) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
        it { expect { permission.update('', attr) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When invalid id' do
        it { expect { permission.update('wrong_id', attr) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When invalid attributes' do
        it { expect { permission.update(new_permission.id, wrong_attr: SecureRandom.hex(6)) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When attributes not a hash value' do
        it { expect { permission.update(new_permission.id, 'not_hash') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When success' do
        subject { permission.update(new_permission.id, attr) }
        it { should_not be raise_error }
      end

      describe 'attributes with descriptions' do
        let(:has_descr) { { name: SecureRandom.hex(6), description: mock_description } }
        let(:no_descr) { { name: SecureRandom.hex(6), description: nil } }
        context 'When missing description value' do
          it { expect { permission.update(new_permission.id, no_descr) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
        end
        context 'When success' do
          subject { permission.update(new_permission.id, has_descr) }
          it { should_not be raise_error }
        end
      end
    end

    describe 'Delete' do
      context 'When missing id' do
        it { expect { permission.delete(nil) }.to raise_error Volcanic::Authenticator::V1::PermissionError }
        it { expect { permission.delete('') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When invalid id' do
        it { expect { permission.delete('wrong_id') }.to raise_error Volcanic::Authenticator::V1::PermissionError }
      end

      context 'When success' do
        subject { permission.delete(new_permission.id) }
        it { should_not be raise_error }
      end
    end
  end
end
