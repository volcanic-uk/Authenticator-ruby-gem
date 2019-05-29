class Configuration
  ##
  # This value need to configure to run these test.
  def initialize
    Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3000'
    Volcanic::Authenticator.config.app_name = 'volcanic'
    Volcanic::Authenticator.config.app_secret = 'volcanic!123'
  end
end

RSpec.describe Volcanic::Authenticator do
  let(:configuration) { Configuration }
  let(:mock_name) { SecureRandom.hex 6 }
  let(:mock_secret) { 'mock_secret' }
  let(:mock_principal_id) { 1 }
  let(:mock_issuer) { 'mock_issuer' }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:principal) { Volcanic::Authenticator::V1::Principal }

  describe 'Configuration' do
    let(:auth_url) { Volcanic::Authenticator.config.auth_url }
    let(:app_name) { Volcanic::Authenticator.config.app_name }
    let(:app_secret) { Volcanic::Authenticator.config.app_secret }
    let(:cache) { Volcanic::Cache::Cache.instance }
    let(:request_app_token_pkey) { Volcanic::Authenticator::V1::TokenKey }
    let(:app_token) { cache.fetch 'volcanic_application_token' }

    context 'When missing or invalid auth_url' do
      it { expect { request_app_token_pkey.request_app_token }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When missing or invalid app_name and app_secret' do
      before do
        Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3000'
        Volcanic::Authenticator.config.app_name = 'app_name'
        Volcanic::Authenticator.config.app_secret = 'app_secret'
      end
      it { expect(app_name).to eq 'app_name' }
      it { expect(app_secret).to eq 'app_secret' }
      it { expect { request_app_token_pkey.request_app_token }.to raise_error Volcanic::Authenticator::AppIdentityError }
    end

    context 'When missing application token' do
      it('should raise exception when request public key')\
          { expect { request_app_token_pkey.request_public_key }.to raise_error Volcanic::Authenticator::AuthorizationError }
    end

    context 'When valid application identity (name and secret)' do
      before { configuration.new }
      it { expect { request_app_token_pkey.fetch_and_request_app_token }.not_to raise_error }
      it('should store token to cache')\
          { expect(app_token).not_to be_empty }
    end
  end

  describe 'Principal' do
    subject(:new_principal) { principal.create(mock_name, 1) }
    describe 'Create' do

      context 'When success' do
        it { is_expected.to be new_principal }
        its(:name) { should_not be nil }
        its(:dataset_id) { should_not be nil }
        its(:id) { should_not be nil }
      end
    end

    describe 'Retrieve' do
      context 'When invalid id'  do
        it { expect { principal.retrieve('wrong_id') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'Retrieve all' do
        subject { principal.retrieve }
        it { should be_an_instance_of(Array) }
        it { should_not be raise_error }
      end

      context 'Retrieve by id' do
        it { is_expected.to be new_principal }
        its(:name) { should_not be nil }
        its(:dataset_id) { should_not be nil }
        its(:id) { should_not be nil }
      end
    end

    describe 'Update' do
      context 'When success update' do
        subject { principal.update(new_principal.id, active: 0) }
        it { should_not be raise_error }
      end
    end

    describe 'Delete' do
      context 'When success delete' do
        subject { principal.delete(new_principal.id) }
        it { should_not be raise_error }
      end
    end
  end

  describe 'Identity' do
    subject(:new_identity) { identity.register(mock_name, nil, mock_principal_id) }
    describe 'registering' do
      context 'When missing name' do
        it { expect { identity.register(nil) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When name too short' do
        it { expect { identity.register('shrt') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When duplicate name' do
        let(:duplicate_name) { SecureRandom.hex 6 }
        before { identity.register(duplicate_name) }
        it { expect { identity.register(duplicate_name) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When identity created' do
        it { is_expected.to be_an identity }
        its(:name) { should_not be nil }
        its(:secret) { should_not be nil }
        its(:id) { should_not be nil }
        it { expect { new_identity.token }.not_to raise_error }
      end

      context 'When identity created with password' do
        subject(:register_with_password) { identity.register(mock_name, mock_secret) }
        it { is_expected.to be_an identity }
        its(:name) { should_not be nil }
        its(:secret) { should eq('mock_secret') }
        its(:id) { should_not be nil }
      end

      context 'Password to short' do
        it { expect { identity.register(mock_name, 'shrt') }.to raise_error Volcanic::Authenticator::ValidationError }
      end
    end

    describe 'login' do
      subject(:token) { new_identity.token }

      context 'When missing name' do
        it { expect { identity.login('', mock_secret, mock_issuer) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When missing password' do
        it { expect { identity.login(mock_name, '', mock_issuer) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When missing issuer' do
        it { expect { identity.login(mock_name, mock_secret, '') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When invalid name or password' do
        it { expect { identity.login('name', 'password', mock_issuer) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When token created' do
        it { should_not be nil }
      end

      context 'When token created by class method' do
        subject { identity.login(new_identity.name, new_identity.secret, mock_issuer) }
        it { should_not be nil }
      end
    end

    describe 'Validating' do
      subject { identity.validate(new_identity.token) }
      context 'When missing token' do
        it { expect(identity.validate(nil)).to be false }
        it { expect(identity.validate('')).to be false }
      end

      context 'When token is invalid' do
        subject { identity.validate(mock_name) }
        it { should be false }
      end

      context 'When token is valid' do
        it { should be true }
      end
    end

    describe 'Token' do
      let(:token) { new_identity.token }
      subject(:new_token) { Volcanic::Authenticator::V1::Token.new(token) }

      context 'When invalid token' do
        subject(:wrong_token) { Volcanic::Authenticator::V1::Token.new('wrong_token') }
        it { expect { wrong_token.decode! }.to raise_error Volcanic::Authenticator::TokenError }
        it { expect { wrong_token.decode_with_claims! }.to raise_error Volcanic::Authenticator::TokenError }
      end

      context 'When fetch claims' do
        before { new_token.decode_with_claims! }
        its(:token) { should_not be nil }
        its(:sub) { should_not be nil }
        its(:principal_id) { should_not be nil }
        its(:identity_id) { should_not be nil }
      end
    end

    describe 'Logout' do
      context 'When missing or invalid token' do
        it { expect { identity.logout(nil) }.to raise_error Volcanic::Authenticator::ValidationError }
        it { expect { identity.logout('') }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When success' do
        it { expect { identity.logout(new_identity.token) }.not_to raise_error }
      end
    end

    describe 'Deactivating' do
      context 'When missing identity id' do
        it { expect { identity.deactivate(nil, new_identity.token) }.to raise_error Volcanic::Authenticator::ConnectionError }
      end

      context 'When invalid identity id' do
        it { expect { identity.deactivate('', new_identity.token) }.to raise_error Volcanic::Authenticator::ConnectionError }
      end

      context 'When missing or invalid token' do
        it { expect { identity.deactivate(new_identity.id, nil) }.to raise_error Volcanic::Authenticator::ValidationError }
      end

      context 'When success' do
        it { expect { identity.deactivate(new_identity.id, new_identity.token) }.not_to raise_error }
      end
    end
  end
end
