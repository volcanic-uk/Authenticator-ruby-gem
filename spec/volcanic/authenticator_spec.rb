class Configuration
  def initialize
    Volcanic::Authenticator.config.app_name = 'volcanic'
    Volcanic::Authenticator.config.app_secret = '60c700b893c858b1abc667efcf71b9c006de7f8a'
  end
end

RSpec.describe Volcanic::Authenticator do
  Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3000'
  let(:configuration) { Configuration }
  let(:mock_name) { SecureRandom.hex 6 }
  let(:mock_secret) { 'mock_secret' }
  subject(:identity_instance) { Volcanic::Authenticator::V1::Identity }

  describe 'Application token' do
    let(:app_name) { Volcanic::Authenticator.config.app_name }
    let(:app_secret) { Volcanic::Authenticator.config.app_secret }
    let(:cache) { Volcanic::Cache::Cache.instance }
    let(:app_token) { cache.fetch 'application_token' }

    context 'When application setting is missing' do
      it { expect { identity_instance.new(mock_name) }.to raise_error Volcanic::Authenticator::InvalidAppToken }
    end

    context 'When missing or invalid credentials' do
      Volcanic::Authenticator.config.app_name = 'app_name'
      Volcanic::Authenticator.config.app_secret = 'app_secret'
      it { expect(app_name).to eq 'app_name' }
      it { expect(app_secret).to eq 'app_secret' }
      it { expect { identity_instance.new(mock_name) }.to raise_error Volcanic::Authenticator::InvalidAppToken }
    end

    context 'When valid credentials' do
      before { configuration.new }
      it { expect { identity_instance.new(mock_name) }.not_to raise_error }
      it('should store token to cache')\
          { expect(app_token).not_to be_empty }
    end
  end

  describe 'Identity' do
    before { configuration.new }
    subject(:identity) { identity_instance.new(mock_name) }

    describe 'registering' do
      context 'When missing name' do
        it { expect { identity.register(nil) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When duplicate name' do
        let(:duplicate_name) { SecureRandom.hex 6 }
        before { identity.register(duplicate_name) }
        it { expect{ identity.register(duplicate_name) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When name too short' do
        it { expect { identity.register('shrt') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When identity created' do
        it { is_expected.to be_an identity_instance }
        its(:name) { should_not be nil }
        its(:secret) { should_not be nil }
        its(:id) { should_not be nil }
      end

      context 'When register other new identity' do
        before { identity.register(SecureRandom.hex 6) }
        it { should be_an identity_instance }
      end

      context 'When identity created with password' do
        subject(:register_with_password) { identity_instance.new(mock_name, mock_secret) }
        it { is_expected.to be_an identity_instance }
        its(:name) { should_not be nil }
        its(:secret) { should eq('mock_secret') }
        its(:id) { should_not be nil }


        context 'Password to short' do
          it { expect{ identity_instance.new(mock_name, 'shrt') }.to raise_error Volcanic::Authenticator::ValidationError }
        end
      end
    end

    describe 'login' do
      # subject(:login) { identity_instance.new(mock_name) }

      context 'When missing name' do
        it { expect { identity.login(nil, mock_secret) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When missing password' do
        it { expect { identity.login(mock_name, nil) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When invalid name or password' do
        it { expect { identity.login('name', 'password') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When token created' do
        before { identity.login }
        its(:token) { is_expected.not_to be nil }
        its(:source_id) { is_expected.not_to be nil }
      end
    end

    describe 'Validating' do
      subject { identity.validation }
      context 'When missing token' do
        it { expect(identity.validation(nil)).to be false }
        it { expect(identity.validation('')).to be false }
      end

      context 'When token is invalid' do
        subject { identity.validation(mock_name) }
        it { should be false }
      end

      context 'When token is valid' do
        before { identity.login }
        it { should be true }
      end
    end

    describe 'Logout' do
      before { identity.login }
      context 'When missing or invalid token' do
        it { expect{ identity.logout(nil) }.to raise_error Volcanic::Authenticator::InvalidToken }
      end

      context 'When success' do
        before { identity.logout }
        its(:token) { should be nil }
        its(:source_id) { should be nil }
      end
    end

    describe 'Deactivating' do
      before { identity.login }

      context 'When missing or invalid identity id' do
        before { identity.deactivate(nil, identity.token) }
        its(:name) { should_not be nil }
        its(:secret) { should_not be nil }
        its(:id) { should_not be nil }
        its(:token) { should_not be nil }
        its(:source_id) { should_not be nil }
      end

      context 'When missing or invalid token' do
        it { expect{ identity.deactivate(identity.id, nil) }.to raise_error Volcanic::Authenticator::InvalidToken }
      end

      context 'When success' do
        before { identity.deactivate }
        its(:name) { should be nil }
        its(:secret) { should be nil }
        its(:id) { should be nil }
        its(:token) { should be nil }
        its(:source_id) { should be nil }
      end
    end
  end
end
