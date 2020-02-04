# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Identity, :vcr do
  before { Configuration.set }
  let(:mock_name) { 'mock_name' }
  let(:mock_principal_id) { 'principal_id' }
  let(:mock_identity_id) { 'mock_identity_id' }
  let(:mock_dataset_id) { 'mock_dataset_id' }
  let(:mock_secret) { 'mock_secret' }
  let(:mock_privileges) { [1, 2] }
  let(:mock_roles) { [1, 2] }
  let(:mock_source) { 'mock_source' }
  let(:mock_source_symbol) { :mock_source }
  let(:mock_random_secret) { 'mock_random_secret' }
  let(:identity) { Volcanic::Authenticator::V1::Identity }
  let(:token) { Volcanic::Authenticator::V1::Token }
  let(:identity_error) { Volcanic::Authenticator::V1::IdentityError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  let(:mock_token_base64) { JSON.parse(Configuration.mock_tokens)['1'] }
  let(:instance) { identity.create(mock_name, mock_principal_id) }

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
      subject { instance }
      its(:id) { should eq mock_identity_id }
      its(:name) { should eq mock_name }
      its(:secret) { should eq mock_secret }
      its(:principal_id) { should eq mock_principal_id }
      its(:dataset_id) { should eq mock_dataset_id }
      its(:source) { should eq 'password' } # default value if not set
    end

    context 'when generating a random secret' do
      subject { identity.create(mock_name, mock_principal_id, secret: nil) }
      its(:secret) { should eq mock_random_secret }
    end

    context 'when create with empty source' do
      it { expect { identity.create(mock_name, mock_principal_id, source: '') }.to raise_error identity_error }
    end

    context 'when create with nil source' do
      subject { identity.create(mock_name, mock_principal_id, source: nil) }
      its(:source) { should eq 'password' } # by default source is set to 'password'
    end

    context 'when create with source value' do
      subject { identity.create(mock_name, mock_principal_id, source: mock_source) }
      its(:source) { should eq mock_source }
    end

    context 'when create with source value (symbol)' do
      subject { identity.create(mock_name, mock_principal_id, source: mock_source_symbol) }
      its(:source) { should eq mock_source }
    end

    context 'when create with source key as string' do
      subject { identity.create(mock_name, mock_principal_id, 'source': mock_source) }
      its(:source) { should eq mock_source }
    end

    context 'when crete with secretless false and secret nil' do
      let(:random_secret) { 'random_secret' }
      subject { identity.create(mock_name, mock_principal_id, 'source': mock_source, secret: nil, secretless: false) }
      its(:source) { should eq mock_source }
      its(:secret) { should eq random_secret } # random secret created by auth service
    end

    context 'when create with source nil, secretless false and secret not nil' do
      let(:secret) { 'my_secret' }
      subject { identity.create(mock_name, mock_principal_id, secret: secret, secretless: false) }
      its(:source) { should eq 'password' }
      its(:secret) { should eq secret }
    end
  end

  describe '#save' do
    subject(:klass) { identity.create(mock_name, mock_principal_id) }

    context 'update name' do
      let(:new_name) { 'new name' }
      before do
        klass.name = new_name
        klass.save
      end
      its(:name) { should eq new_name }
    end

    context 'update role ids' do
      let(:new_role_ids) { [3, 4] }
      before { klass.update_role_ids(new_role_ids) }
      its(:role_ids) { should eq new_role_ids }
    end

    context 'update privilege ids' do
      let(:new_privilege_ids) { [3, 4] }
      before { klass.update_privilege_ids(new_privilege_ids) }
      its(:privilege_ids) { should eq new_privilege_ids }
    end
  end

  describe '#reset_secret' do
    subject(:klass) { identity.create(mock_name, mock_principal_id) }
    
    context 'when random secret' do
      before { klass.reset_secret }
      its(:secret) { should eq mock_secret }
    end

    context 'when custom secret' do
      let(:custom_secret) { 'custom_secret' }
      before { klass.reset_secret(custom_secret) }
      its(:secret) { should eq custom_secret }
    end
  end

  describe '#delete' do
    subject(:klass) { identity.create(mock_name, mock_principal_id) }
    context 'when deleted' do
      before { klass.delete }
      it { expect { klass.delete }.to raise_error identity_error }
    end
  end

  describe '#login' do
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
      subject { identity.new(name: mock_name, secret: mock_secret, dataset_id: mock_dataset_id).login }
      its(:token_base64) { is_expected.to eq mock_token_base64 }
    end

    context 'when generating token' do
      subject { identity.new(id: mock_identity_id).token }
      its(:token_base64) { is_expected.to eq mock_token_base64 }
    end

    context 'when generating token with args' do
      let(:mock_nbf) { 1_571_708_316_000 }
      let(:mock_exp) { 1_571_794_716_000 }
      let(:mock_audience) { ['*'] }
      let(:args) { { audience: mock_audience, nbf: mock_nbf, exp: mock_exp, single_use: true } }
      subject { identity.new(id: mock_identity_id).token(args) }
      its(:token_base64) { is_expected.to eq mock_token_base64 }
    end
  end

  describe '.find' do
    context 'when find by id' do
      subject { identity.find_by_id(mock_identity_id) }
      its(:id) { should eq mock_identity_id }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
      its(:source) { should eq 'password' }
      its(:secret) { should eq nil } # secret will not be returning when finding
    end

    context 'when find with specific page' do
      subject(:identities) { identity.find(page: 1) }
      it { expect(identities[0].id).to eq 1 }
      it { expect(identities.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:identities) { identity.find(page_size: 2) }
      it { expect(identities[0].id).to eq 1 }
      it { expect(identities.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:identities) { identity.find(page: 2, page_size: 3) }
      it { expect(identities[0].id).to eq 4 }
      it { expect(identities.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:identities) { identity.find(query: 'vol') }
      it { expect(identities[0].name).to eq 'volcanic' }
      it { expect(identities[1].name).to eq 'volcanic2' }
    end

    context 'when find with pagination' do
      subject(:identities) { identity.find }
      it { expect(identities.page).to eq 1 }
      it { expect(identities.page_size).to eq 10 }
      it { expect(identities.row_count).to eq 5 }
      it { expect(identities.page_count).to eq 1 }
    end

    context 'when find with sort and order' do
      subject(:identities) { identity.find(sort: 'id', order: 'desc') }
      it { expect(identities[0].id).to eq 5 }
      it { expect(identities[1].id).to eq 4 }
      it { expect(identities[2].id).to eq 3 }
    end

    context 'when find with name' do
      subject(:identities) { identity.find(name: 'volcanic') }
      it { expect(identities.first.name).to eq 'volcanic' }
    end

    context 'when find with name that has special character' do
      subject(:identities) { identity.find(name: 'volcanic_ý') }
      it { expect(identities.first.name).to eq 'volcanic_ý' }
    end

    context 'when find with name that has + character ' do
      subject(:identities) { identity.find(name: 'volcanic+1234') }
      it { expect(identities.first.name).to eq 'volcanic+1234' }
    end
  end

  describe '#deactivate!' do
    subject(:klass) { identity.create(mock_name, mock_principal_id) }

    context 'when still activated' do
      it { expect { klass.deactivate! }.not_to raise_error }
    end

    context 'when already deactivated' do
      before { klass.deactivate! }
      it { expect { klass.deactivate! }.to raise_error identity_error }
    end

    context 'when not existed' do
      before { klass.id = 'nil' }
      it { expect { klass.deactivate! }.to raise_error identity_error }
    end
  end

  describe '#activate!' do
    subject(:klass) { identity.create(mock_name, mock_principal_id) }

    context 'when activated' do
      it { expect { klass.activate! }.not_to raise_error }
    end

    context 'when deactivated' do
      before { klass.deactivate! }
      it { expect { klass.activate! }.not_to raise_error }
    end

    context 'when not existed' do
      before { klass.id = 'nil' }
      it { expect { klass.activate! }.to raise_error identity_error }
    end
  end
end
