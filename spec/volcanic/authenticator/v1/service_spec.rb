RSpec.describe Volcanic::Authenticator::V1::Service do
  before { Configuration.set }
  let(:service) { Volcanic::Authenticator::V1::Service }
  let(:mock_name) { SecureRandom.hex(6) }
  let(:mock_description) { 'mock_description' }

  subject(:new_service) { service.create(mock_name) }

  describe 'Create' do
    context 'When missing name' do
      it { expect { service.create(nil) }.to raise_error Volcanic::Authenticator::ServiceError }
      it { expect { service.create('') }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When invalid/short name' do
      it { expect { service.create('shrt') }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When duplicate name' do
      let(:duplicate_name) { SecureRandom.hex 6 }
      before { service.create(duplicate_name) }
      it { expect { service.create(duplicate_name) }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When creating' do
      it { is_expected.to be_an service }
      its(:name) { should_not be nil }
      its(:id) { should_not be nil }
    end
  end

  describe 'Read all' do
    subject { service.all}
    it { should be_an_instance_of(Array) }
  end

  describe 'Read by given id' do
    subject { service.find_by_id(new_service.id)}
    context 'When missing id' do
      it { expect { service.find_by_id(nil) }.to raise_error Volcanic::Authenticator::ServiceError }
      it { expect { service.find_by_id('') }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When invalid id' do
      it { expect { service.find_by_id('wrong_id') }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When success' do
      it { is_expected.to be_an service }
    end
  end

  describe 'Update' do
    let(:attr) { { name: SecureRandom.hex(6) } }
    context 'When missing id' do
      it { expect { service.update(nil, attr) }.to raise_error Volcanic::Authenticator::ConnectionError }
      it { expect { service.update('', attr) }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When invalid id' do
      it { expect { service.update('wrong_id', attr) }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When invalid attributes' do
      it { expect { service.update(new_service.id, wrong_attr: SecureRandom.hex(6)) }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When attributes not a hash value' do
      it { expect { service.update(new_service.id, 'not_hash') }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When success' do
      subject { service.update(new_service.id, attr) }
      it { should_not be raise_error }
    end
  end

  describe 'Delete' do
    context 'When missing id' do
      it { expect { service.delete(nil) }.to raise_error Volcanic::Authenticator::ConnectionError }
      it { expect { service.delete('') }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When invalid id' do
      it { expect { service.delete('wrong_id') }.to raise_error Volcanic::Authenticator::ServiceError }
    end

    context 'When success' do
      subject { service.delete(new_service.id) }
      it { should_not be raise_error }
    end
  end
end

