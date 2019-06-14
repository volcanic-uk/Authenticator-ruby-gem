RSpec.describe Volcanic::Authenticator do
  let(:configuration) { Configuration }
  let(:mock_name) { SecureRandom.hex 6 }
  let(:mock_secret) { 'mock_secret' }
  let(:mock_principal_id) { 1 }
  let(:mock_issuer) { 'mock_issuer' }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:principal) { Volcanic::Authenticator::V1::Principal }

  describe 'Configuration' do
    before { configuration.reset }
    let(:auth_url) { Volcanic::Authenticator.config.auth_url }
    let(:app_name) { Volcanic::Authenticator.config.app_name }
    let(:app_secret) { Volcanic::Authenticator.config.app_secret }
    let(:cache) { Volcanic::Cache::Cache.instance }
    let(:request_app_token_pkey) { Volcanic::Authenticator::V1::TokenKey }
    let(:app_token) { cache.fetch 'volcanic_application_token' }

    context 'When missing or invalid auth_url' do
      it { expect { request_app_token_pkey.request_app_token }.to raise_error Volcanic::Authenticator::ConnectionError }
    end

    context 'When missing app_name, app_secret' do
      before { Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3003' }
      it { expect(app_name).to eq nil }
      it { expect(app_secret).to eq nil }
      it { expect { request_app_token_pkey.request_app_token }.to raise_error Volcanic::Authenticator::ApplicationError }
    end

    context 'When missing application token' do
      before { Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3003' }
      it('should raise ApplicationError when request public key')\
          { expect { request_app_token_pkey.request_public_key('') }.to raise_error Volcanic::Authenticator::ApplicationError }
    end

    context 'When valid application identity (name and secret)' do
      before { configuration.set }
      it { expect { request_app_token_pkey.fetch_and_request_app_token }.not_to raise_error }
      it('should store token to cache')\
          { expect(app_token).not_to be_empty }
      it('should raise KeyError when invalid public key id')\
        { expect { request_app_token_pkey.request_public_key('wrong_kid') }.to raise_error Volcanic::Authenticator::KeyError }
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
      context 'When invalid id' do
        it { expect { principal.retrieve('wrong_id') }.to raise_error Volcanic::Authenticator::PrincipalError }
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
      context 'When name is nil' do
        it { expect { identity.register(nil) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When name is empty' do
        it { expect { identity.register('') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When name too short' do
        it { expect { identity.register('shrt') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When name too long' do
        it { expect { identity.register(SecureRandom.hex(33)) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When invalid name' do
        it { expect { identity.register('white space') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When duplicate name' do
        let(:duplicate_name) { SecureRandom.hex 6 }
        before { identity.register(duplicate_name) }
        it { expect { identity.register(duplicate_name) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When identity created' do
        it { is_expected.to be_an identity }
        its(:name) { should_not be nil }
        its(:secret) { should_not be nil }
        its(:id) { should_not be nil }
        it { expect { new_identity.token }.not_to raise_error }
      end

      context 'When password is nil' do
        it { expect { identity.register(mock_name, nil) }.not_to raise_error }
      end

      context 'When password is empty' do
        it { expect { identity.register(mock_name, '') }.not_to raise_error }
      end

      context 'When password too short' do
        it { expect { identity.register(mock_name, 'shrt') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When identity created with password' do
        subject(:register_with_password) { identity.register(mock_name, mock_secret) }
        it { is_expected.to be_an identity }
        its(:name) { should_not be nil }
        its(:secret) { should be nil }
        its(:id) { should_not be nil }
      end
    end

    describe 'login' do
      subject(:token) { new_identity.token }

      context 'When missing name' do
        it { expect { identity.login('', mock_secret) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When missing password' do
        it { expect { identity.login(mock_name, '') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When invalid name or password' do
        it { expect { identity.login('name', 'password') }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When token created' do
        it { should_not be nil }
      end

      context 'When token created by class method' do
        subject { identity.login(new_identity.name, new_identity.secret) }
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
        it { expect(identity.validate(mock_name)).to be false }
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
        it { expect { identity.logout(nil) }.to raise_error Volcanic::Authenticator::IdentityError }
        it { expect { identity.logout('') }.to raise_error Volcanic::Authenticator::IdentityError }
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
        it { expect { identity.deactivate(new_identity.id, nil) }.to raise_error Volcanic::Authenticator::IdentityError }
      end

      context 'When success' do
        it { expect { identity.deactivate(new_identity.id, new_identity.token) }.not_to raise_error }
      end
    end
  end
end
