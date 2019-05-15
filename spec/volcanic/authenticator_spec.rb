class Configuration
  def initialize
    Volcanic::Authenticator.config.app_name = 'volcanic'
    Volcanic::Authenticator.config.app_secret = '60c700b893c858b1abc667efcf71b9c006de7f8a'
  end
end

RSpec.describe Volcanic::Authenticator do
  Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3000'
  let(:configuration) { Configuration }
  let(:name) { SecureRandom.hex 6 }
  let(:password) { :name }
  subject(:identity) { Volcanic::Authenticator::V1::Identity.new }

  describe 'Application token' do
    let(:app_name) { Volcanic::Authenticator.config.app_name }
    let(:app_secret) { Volcanic::Authenticator.config.app_secret }
    let(:cache) { Volcanic::Cache::Cache.instance }
    let(:app_token) { cache.fetch 'application_token' }

    context 'When application setting is missing' do
      it { expect { identity.register(name) }.to raise_error Volcanic::Authenticator::InvalidAppToken }
    end

    context 'When missing or invalid credentials' do
      Volcanic::Authenticator.config.app_name = 'app_name'
      Volcanic::Authenticator.config.app_secret = 'app_secret'
      it { expect(app_name).to eq 'app_name' }
      it { expect(app_secret).to eq 'app_secret' }
      it { expect { identity.register(name) }.to raise_error Volcanic::Authenticator::InvalidAppToken }
    end

    context 'When valid credentials' do
      before { configuration.new }
      it { expect { identity.register(name) }.not_to raise_error }
      it('should store token to cache')\
          { expect(app_token).not_to be_empty }
    end
  end

  describe 'Identity' do
    before { configuration.new }
    subject(:register) { identity.register(name) }
    let(:i_name) { JSON.parse(register)['identity_name'] }
    let(:i_secret) { JSON.parse(register)['identity_secret'] }
    let(:login) { identity.login(i_name, i_secret) }
    let(:token) { JSON.parse(login)['token'] }

    describe 'registering' do
      context 'When missing name' do
        it { expect { identity.register(nil) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When duplicate name' do
        duplicate_name = SecureRandom.hex(6)
        before { identity.register(duplicate_name) }
        it { expect { identity.register(duplicate_name) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When name short' do
        it { expect { identity.register('shrt') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When identity created' do
        it { expect { register }.not_to raise_error }
        it { should_not be_empty }
      end

      context 'When identity created with password' do
        subject(:register_with_password) { identity.register(name, nil, 'password') }
        it { expect { register_with_password }.not_to raise_error }
        it { should_not be_empty }
        it { expect(JSON.parse(register_with_password)['identity_secret']).to eq 'password' }
      end
    end

    describe 'login' do
      context 'When missing name' do
        it { expect { identity.login(nil, password) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When missing password' do
        it { expect { identity.login(name, nil) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When invalid name or password' do
        it { expect { identity.login('name', 'password') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When token created' do
        subject { identity.login(i_name, i_secret) }
        it { should_not be raise_error }
        it { should_not be_empty }
      end
    end

    describe 'Validating' do
      context 'When missing token' do
        it { expect(identity.validation(nil)).to eq false }
        it { expect(identity.validation('')).to eq false }
      end

      context 'When token is invalid' do
        subject { identity.validation(name) }
        it { should eq false }
      end

      context 'When token is valid' do
        subject { identity.validation(token) }
        it { should eq true }
      end
    end

    describe 'Deactivating' do
      let(:identity_id) { JSON.parse(login)['id'] }
      context 'When missing identity id' do
        # subject { identity.deactivate(nil, token) }
        # it { should eq nil }
      end

      context 'When missing or invalid token' do
        subject { identity.deactivate(identity_id, nil) }
        it { should eq nil }
      end

      context 'When success' do
        subject { identity.deactivate(identity_id, token) }
        it { should eq 'OK' }
      end
    end

    describe 'Logout' do
      context 'When missing or invalid token' do
        subject { identity.logout(nil) }
        it { should eq nil }
      end

      context 'When success' do
        subject { identity.logout(token) }
        it { should eq 'OK' }
      end
    end
  end
end
