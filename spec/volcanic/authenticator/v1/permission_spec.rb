RSpec.describe Volcanic::Authenticator::V1::Permission do
  before { Configuration.set }
  let(:permission) { Volcanic::Authenticator::V1::Permission }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }
  describe 'Permission' do
    subject(:new_permission) { permission.create(mock_name) }
    describe 'Create' do
      context 'When missing name' do
        it { expect { permission.create(nil) }.to raise_error Volcanic::Authenticator::PermissionError }
        it { expect { permission.create('') }.to raise_error Volcanic::Authenticator::PermissionError }
      end

      context 'When invalid/short name' do
        it { expect { permission.create('shrt') }.to raise_error Volcanic::Authenticator::PermissionError }
      end

      context 'When duplicate name' do
        let(:duplicate_name) { SecureRandom.hex 6 }
        before { permission.create(duplicate_name) }
        it { expect { permission.create(duplicate_name) }.to raise_error Volcanic::Authenticator::PermissionError }
      end

      context 'When success' do
        its(:name) { should_not be nil }
        its(:id) { should_not be nil }
        its(:creator_id) { should_not be nil }
      end

      context 'with description' do
        subject { permission.create(mock_name, mock_description) }
        its(:description) { should_not be nil }
      end
    end

    describe 'Get all' do
      subject { permission.all }
      it { should be_an_instance_of(Array) }
    end

    describe 'Find by given id' do
      context 'When missing id' do
        it { expect { permission.find_by_id(nil) }.to raise_error Volcanic::Authenticator::ConnectionError }
        it { expect { permission.find_by_id('') }.to raise_error Volcanic::Authenticator::ConnectionError }
      end

      context 'When invalid id' do
        it { expect { permission.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::PermissionError }
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
        it { expect { permission.update(nil, attr) }.to raise_error Volcanic::Authenticator::ConnectionError }
        it { expect { permission.update('', attr) }.to raise_error Volcanic::Authenticator::ConnectionError }
      end

      context 'When invalid id' do
        it { expect { permission.update('wrong_id', attr) }.to raise_error Volcanic::Authenticator::PermissionError }
      end

      context 'When invalid attributes' do
        it { expect { permission.update(new_permission.id, wrong_attr: SecureRandom.hex(6)) }.to raise_error Volcanic::Authenticator::PermissionError }
      end

      context 'When success' do
        subject { permission.update(new_permission.id, attr) }
        it { should_not be raise_error }
      end
    end

    describe 'Delete' do
      context 'When missing id' do
        it { expect { permission.delete(nil) }.to raise_error Volcanic::Authenticator::ConnectionError }
        it { expect { permission.delete('') }.to raise_error Volcanic::Authenticator::ConnectionError }
      end

      context 'When invalid id' do
        it { expect { permission.delete('wrong_id') }.to raise_error Volcanic::Authenticator::PermissionError }
      end

      context 'When success' do
        subject { permission.delete(new_permission.id) }
        it { should_not be raise_error }
      end
    end
  end
end

