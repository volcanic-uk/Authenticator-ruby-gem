# frozen_string_literal: true

RSpec.describe Volcanic::Authenticator::V1::Principal, :vcr do
  before { Configuration.set }
  let(:principal) { Volcanic::Authenticator::V1::Principal }
  let(:mock_name) { 'mock_name' }
  let(:mock_dataset_id) { '1' }
  let(:mock_roles) { [1, 2] }
  let(:mock_privileges) { [3, 4] }
  let(:principal_error) { Volcanic::Authenticator::V1::PrincipalError }
  let(:authorization_error) { Volcanic::Authenticator::V1::AuthorizationError }
  let(:new_principal) { Volcanic::Authenticator::V1::Principal.create(mock_name, mock_dataset_id, mock_roles, mock_privileges) }
  describe '#create' do
    context 'when missing name' do
      it { expect { principal.create(nil, 1) }.to raise_error principal_error }
      it { expect { principal.create('', 1) }.to raise_error principal_error }
    end

    context 'when duplicate name' do
      before { principal.create(mock_name, mock_dataset_id) }
      it { expect { principal.create(mock_name, mock_dataset_id) }.to raise_error principal_error }
    end

    context 'when success' do
      subject { new_principal }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
    end
  end

  describe '#find' do
    context 'when find by id' do
      subject { principal.find_by_id(1) }
      its(:id) { should eq 1 }
      its(:name) { should eq mock_name }
      its(:dataset_id) { should eq mock_dataset_id }
    end

    context 'when find with specific page' do
      subject(:principals) { principal.find(page: 2) }
      it { expect(principals[0].id).to eq 11 }
      it { expect(principals.count).to be <= 10 } # taking the page size to 10
    end

    context 'when find with specific page size' do
      subject(:principals) { principal.find(page_size: 2) }
      it { expect(principals[0].id).to eq 1 }
      it { expect(principals.count).to be <= 2 }
    end

    context 'when find with page and page size' do
      subject(:principals) { principal.find(page: 2, page_size: 3) }
      it { expect(principals[0].id).to eq 4 }
      it { expect(principals.count).to be <= 3 }
    end

    context 'when find with query' do
      subject(:principals) { principal.find(query: 'vol') }
      it { expect(principals[0].name).to eq 'volcanic' }
      it { expect(principals[1].name).to eq 'vol' }
    end

    context 'when find with pagination' do
      subject(:principals) { principal.find }
      it { expect(principals.page). to eq 1 }
      it { expect(principals.page_size). to eq 10 }
      it { expect(principals.row_count). to eq 20 }
      it { expect(principals.page_count). to eq 2 }
    end

    context 'when find with name' do
      subject(:principals) { principal.find(name: 'volcanic') }
      it { expect(principals.first.name).to eq 'volcanic' }
    end

    context 'when find with name that has special character' do
      subject(:principals) { principal.find(name: 'volcanic_ý') }
      it { expect(principals.first.name).to eq 'volcanic_ý' }
    end

    context 'when find with name that has + character ' do
      subject(:principals) { principal.find(name: 'volcanic+1234') }
      it { expect(principals.first.name).to eq 'volcanic+1234' }
    end
  end

  describe '#save' do
    let(:new_name) { 'new-principal' }

    context 'when required field is nil' do
      before { new_principal.name = nil }
      it { expect { new_principal.save }.to raise_error principal_error }
    end

    context 'when required field is empty' do
      before { new_principal.name = nil }
      it { expect { new_principal.save }.to raise_error principal_error }
    end

    context 'when changed name' do
      before do
        new_principal.name = new_name
        new_principal.save
      end
      subject { principal.find_by_id(new_principal.id) }
      its(:name) { should eq new_name }
    end
  end

  describe '#delete' do
    context 'when deleted' do
      before { new_principal.delete }
      subject { principal.find_by_id(new_principal.id) }
      its(:active?) { should eq false }
    end

    context 'when invalid or non-exist id' do
      it { expect { principal.new(id: 'wrong-id').delete }.to raise_error principal_error }
      it { expect { principal.new(id: 123_456_789).delete }.to raise_error principal_error }
    end
  end

  describe '#update_role_ids' do
    subject(:principal_update) { new_principal }

    context 'When role id is nil' do
      before { principal_update.update_role_ids(nil) }
      its(:role_ids) { should eq [] }
    end

    context 'When updating with integer and strings' do
      before { principal_update.update_role_ids(1, '2') }
      its(:role_ids) { should eq [1, 2] }
    end

    context 'When updating with array value' do
      before { principal_update.update_role_ids([1, 2]) }
      its(:role_ids) { should eq [1, 2] }
    end

    context 'When updating with empty array' do
      before { principal_update.update_role_ids([]) }
      its(:role_ids) { should eq [] }
    end
  end

  describe '#update_privilege_ids' do
    subject(:principal_update) { new_principal }

    context 'When role id is nil' do
      before { principal_update.update_privilege_ids(nil) }
      its(:privilege_ids) { should eq [] }
    end

    context 'When updating with integer and strings' do
      before { principal_update.update_privilege_ids(1, '2') }
      its(:privilege_ids) { should eq [1, 2] }
    end

    context 'When updating with array value' do
      before { principal_update.update_privilege_ids([1, 2]) }
      its(:privilege_ids) { should eq [1, 2] }
    end

    context 'When updating with empty array' do
      before { principal_update.update_privilege_ids([]) }
      its(:privilege_ids) { should eq [] }
    end
  end

  describe '#deactivate!' do
    subject(:princ) { new_principal }

    context 'when activated' do
      it { expect { princ.deactivate! }.not_to raise_error }
    end

    context 'when deactivated' do
      before { princ.deactivate! }
      it { expect { princ.deactivate! }.to raise_error principal_error }
    end

    context 'when not existed' do
      before { princ.id = 'nil' }
      it { expect { princ.deactivate! }.to raise_error principal_error }
    end

    context 'when not allowed' do
      before { Configuration.set_authorize_identity }
      it { expect { princ.deactivate! }.to raise_error authorization_error }
    end
  end

  describe '#activate!' do
    subject(:princ) { new_principal }

    context 'when activated' do
      it { expect { princ.activate! }.not_to raise_error }
    end

    context 'when deactivated' do
      before { princ.deactivate! }
      it { expect { princ.activate! }.not_to raise_error }
    end

    context 'when not existed' do
      before { princ.id = 'nil' }
      it { expect { princ.activate! }.to raise_error principal_error }
    end

    context 'when not allowed' do
      before { Configuration.set_authorize_identity }
      it { expect { princ.activate! }.to raise_error authorization_error }
    end
  end
end
