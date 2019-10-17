# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Identity, :vcr do
  before { Configuration.set }
  let(:mock_name) { 'mock_name' }
  let(:mock_principal_id) { 1 }
  let(:mock_secret) { 'mock_secret' }
  let(:mock_privileges) { [1, 2] }
  let(:mock_roles) { [1, 2] }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:new_identity) { identity.create(mock_name, mock_principal_id, secret: mock_secret) }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }

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
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:secret) { should eq mock_secret }
      its(:principal_id) { should eq 1 }
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

    context 'update roles' do
      let(:new_roles) { [1, 2] }
      # before { identity_update.update_roles(new_roles) }
      # TODO: test should return collection of roles
    end

    context 'update privileges' do
      let(:new_privileges) { [1, 2] }
      # before { identity_update.update_privileges(new_privileges) }
      # TODO: test should return collection of privileges
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
    let(:identity_delete) { new_identity }
    context 'when deleted' do
      before { identity_delete.delete }
      it { expect { identity_delete.delete }.to raise_error identity_error }
    end
  end
end
