# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Identity, :vcr do
  before { Configuration.set }
  let(:mock_name) { 'mock_name' }
  let(:mock_principal_id) { '25f5dad773' }
  let(:mock_secret) { 'mock_secret' }
  let(:mock_privileges) { [1, 2] }
  let(:mock_roles) { [1, 2] }
  let(:new_identity) { identity.create(mock_name, mock_principal_id, secret: mock_secret) }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  let(:mock_tokens) { JSON.parse(Configuration.mock_tokens) }
  let(:mock_token_base64) { mock_tokens['1'] }

  describe '#create' do
    context 'when missing name' do
      it { expect { identity.create(nil, mock_principal_id) }.to raise_error identity_error }
      it { expect { identity.create('', mock_principal_id) }.to raise_error identity_error }
    end

    context 'when duplicate name' do
      before { identity.create('duplicate-name', mock_principal_id) }
      it { expect { identity.create('duplicate-name', mock_principal_id) }.to raise_error identity_error }
    end

    context 'when missing principal id' do
      it { expect { identity.create(mock_name, nil) }.to raise_error identity_error }
      it { expect { identity.create(mock_name, '') }.to raise_error identity_error }
    end

    context 'when invalid/non exists principal id' do
      it { expect { identity.create(mock_name, 'wrong-id') }.to raise_error identity_error }
      it { expect { identity.create(mock_name, 123_456_789) }.to raise_error identity_error }
    end

    context 'when success' do
      subject { new_identity }
      its(:id) { should eq 'deb526106b' }
      its(:name) { should eq mock_name }
      its(:secret) { should eq mock_secret }
      its(:principal_id) { should eq 1 }
      its(:dataset_id) { should eq '-1' }
    end

    context 'when generating a random secret' do
      subject { identity.create(mock_name, mock_principal_id, secret: nil) }
      its(:secret) { should eq 'cded0d177c84163f1a460f573b9b14e1b8b1e515' }
    end
  end

  describe '#update' do
    subject(:identity_update) { new_identity }

    context 'update name' do
      let(:new_name) { 'new name' }
      before do
        identity_update.name = new_name
        identity_update.save
      end
      its(:name) { should eq new_name }
    end

    context 'update role ids' do
      let(:new_role_ids) { [3, 4] }
      before { identity_update.update_role_ids(new_role_ids) }
      its(:role_ids) { should eq new_role_ids }
    end

    context 'update privilege ids' do
      let(:new_privilege_ids) { [3, 4] }
      before { identity_update.update_privilege_ids(new_privilege_ids) }
      its(:privilege_ids) { should eq new_privilege_ids }
    end
  end

  describe '#reset_secret' do
    subject(:identity_secret) { new_identity }
    context 'when random secret' do
      before { identity_secret.reset_secret }
      its(:secret) { should eq '4af4da0f2b2af5b217cfd726b84ba76bc47d3b21' }
    end

    context 'when custom secret' do
      let(:custom_secret) { 'custom_secret' }
      before { identity_secret.reset_secret(custom_secret) }
      its(:secret) { should eq custom_secret }
    end
  end

  describe '#delete' do
    subject(:identity_delete) { new_identity }
    context 'when deleted' do
      before { identity_delete.delete }
      it { expect { identity_delete.delete }.to raise_error identity_error }
    end
  end

  describe '#login' do
    subject(:identity_login) { new_identity }

    context 'When name is missing' do
      it { expect { identity.new(name: '').login }.to raise_error identity_error }
      it { expect { identity.new(name: nil).login }.to raise_error identity_error }
    end

    context 'When secret is missing' do
      it { expect { identity.new(name: mock_name, secret: '').login }.to raise_error identity_error }
      it { expect { identity.new(name: mock_name, secret: nil).login }.to raise_error identity_error }
    end

    context 'When principal_id is missing' do
      it { expect { identity.new(name: mock_name, secret: '1234', principal_id: '').login }.to raise_error identity_error }
      it { expect { identity.new(name: mock_name, secret: '1234', principal_id: nil).login }.to raise_error identity_error }
    end

    context 'when login' do
      subject { identity_login.login }
      its(:token_base64) { is_expected.to eq mock_token_base64 }
    end

    context 'when generating token' do
      subject { identity.new(id: 1).token }
      its(:token_base64) { is_expected.to eq mock_token_base64 }
    end

    context 'when generating token with args' do
      let(:args) { { audience: ['*'], nbf: 1_571_708_316_000, exp: 1_571_794_716_000, single_use: true } }
      subject { identity.new(id: 1).token(args) }
      its(:token_base64) { is_expected.to eq mock_token_base64 }
    end
  end
end
