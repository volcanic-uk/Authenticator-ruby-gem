# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Identity, :vcr do
  before { Configuration.set }
  let(:mock_name) { 'mock_name' }
  let(:mock_principal_id) { 1 }
  let(:mock_secret) { 'mock_secret' }
  let(:mock_privileges) { [1, 2] }
  let(:mock_roles) { [1, 2] }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:new_identity) { identity.create(mock_name, mock_principal_id, secret: mock_secret, privileges: mock_privileges, roles: mock_roles) }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }

  describe '.create' do
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
      # it { expect { identity.create(mock_name, 123_456_789) }.to raise_error identity_error }
    end

    context 'when success' do
      subject { new_identity }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:secret) { should eq mock_secret }
      its(:principal_id) { should eq 1 }
    end

    context 'when generating a custom secret' do
      subject { identity.create(mock_name, mock_principal_id, secret: nil) }
      its(:secret) { should eq 'cded0d177c84163f1a460f573b9b14e1b8b1e515' }
    end
  end

  describe '.save' do
    let(:new_name) { 'new_name' }
    let(:new_principal_id) { 2 }

    context 'When required field is nil' do
      before { new_identity.name = nil }
      it { expect { new_identity.save }.to raise_error identity_error }
    end

    context 'When required field is empty' do
      before { new_identity.name = '' }
      it { expect { new_identity.save }.to raise_error identity_error }
    end

    # context 'When changed name' do
    #   before do
    #     new_identity.name = new_name
    #     new_identity.save
    #   end
    #   subject { role.find(new_identity.id) }
    #   its(:name) { should eq new_name }
    # end

    # context 'When update with existing name' do
    #   before { new_identity.name = new_name }
    #   it { expect { new_identity.save }.to raise_error identity_error }
    # end
  end

  describe '.reset_secret' do
    subject(:ident) { new_identity }
    context 'when secret is nil' do
      before { ident.reset_secret }
      its(:secret) { should eq '3cdfe148d7c13178fb829935508e3541ac79e19a' }
    end

    context 'when secret is not nil' do
      let(:update_secret) { 'update_secret' }
      before { ident.reset_secret(update_secret) }
      its(:secret) { should eq update_secret }
    end
  end

  describe 'Token' do
    # let(:name) { new_identity.name }
    # let(:secret) { new_identity.secret }
    # let(:gen_token) { 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImE1ZjUzZmEyNWYyZjgyYTM4NDNjNGFmMTFiZDgwMWExIn0.eyJleHAiOjE1NjM2MDQ5MDIsInN1YiI6InVzZXI6Ly91bmRlZmluZWQvbnVsbC8xLzM0LzU3IiwibmJmIjoxNTYyNzQwOTAyLCJhdWRpZW5jZSI6WyIqIl0sImlhdCI6MTU2Mjc0MDkwMiwiaXNzIjoidm9sY2FuaWNfYXV0aF9zZXJ2aWNlX2FwMiJ9.AN0RL1lBtPfOjEYt52pvVpT-GxhDJHi7M-nKPTrnUZa70bSlvx0Uj0SCeHXQ5mpQy6isivnUq00fBytSYvCf1ZFbAY-Nfn7dIMaNoeL_QIjefVyrhnY8fgDY0GjYXLboWJB0sS1j1yLpCr7SnXdX1FYwAGPCsTDy1ccgixuLlEqWEH_v' }
    # context 'when generate a token' do
    #   subject { identity.new(name: name, secret: secret) }
    #   its(:token) { should eq gen_token }
    # end
    #
    # context 'when missing name or secret' do
    #   it { expect { identity.new.token }.to raise_error identity_error }
    # end
    #
    # context 'when invalid name' do
    #   it { expect { identity.new(name: 'wrong-name', secret: secret).token }.to raise_error authorization_error }
    # end
    #
    # context 'when invalid secret' do
    #   it { expect { identity.new(name: 'wrong-name', secret: secret).token }.to raise_error authorization_error }
    # end
  end

  describe '.delete' do
    let(:identity_id) { new_identity.id }
    # context 'when deleted' do
    #   before { new_identity.delete }
    #   it { expect { new_identity.token }.to raise_error authorization_error }
    # end

    context 'when identity already been deleted' do
      it { expect { identity.new(id: 2).delete }.to raise_error identity_error }
    end

    context 'when invalid or non-exist id' do
      # it { expect { identity.new(id: 'wrong-id').delete }.to raise_error identity_error }
      it { expect { identity.new(id: 123_456_789).delete }.to raise_error identity_error }
    end
  end
end
